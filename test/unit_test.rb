# frozen_string_literal: true

# Unitários: o que a conformidade não cobre (ou cobre só de um jeito) — rede fora do ar,
# idempotência do usuário, retry/backoff, codificação, omitido × nulo, upload, erros, webhooks.

require "pathname"
require "socket"
require "stringio"
require "tempfile"
require "test_helper"

class NetworkTest < Minitest::Test
  def closed_port
    probe = TCPServer.new("127.0.0.1", 0)
    port = probe.addr[1]
    probe.close # ninguém escuta nesta porta
    port
  end

  def test_servidor_fora_do_ar_vira_network_error
    sleeps = []
    bz = Bzapper::Client.new("bz_live_unit", base_url: "http://127.0.0.1:#{closed_port}", timeout: 2,
                                             sleeper: ->(s) { sleeps << s })
    error = assert_raises(Bzapper::NetworkError) { bz.instances.get_instance("i1") }
    assert_kind_of Bzapper::Error, error
    assert_equal [0, "NETWORK_ERROR"], [error.status, error.code]
    assert_match(/\A[0-9a-f]{32}\z/, error.request_id, "request_id = o X-Request-Id enviado")
    assert_equal 2, sleeps.size, "rede é repetida max_retries vezes"
    sleeps.each_with_index { |s, i| assert_operator s, :>=, 0.5 * (2**i) }
    refute_nil error.cause
  end

  # Servidor que lê a requisição e fecha sem responder: dá para conferir que o `request_id` do
  # erro é EXATAMENTE o `X-Request-Id` enviado — e o mesmo em todas as tentativas.
  def test_request_id_do_network_error_e_o_enviado
    server = TCPServer.new("127.0.0.1", 0)
    seen = []
    thread = Thread.new do
      3.times do
        socket = server.accept
        while (line = socket.gets("\r\n")) && line != "\r\n"
          name, value = line.split(":", 2)
          seen << value.strip if name.casecmp?("x-request-id")
        end
        socket.close
      end
    rescue IOError
      nil
    end
    bz = Bzapper::Client.new("bz_live_unit", base_url: "http://127.0.0.1:#{server.addr[1]}", sleeper: ->(_s) {})
    error = assert_raises(Bzapper::NetworkError) { bz.messages.send_text(to: "5511999990000", body: "oi") }
    thread.join(5)
    assert_equal 3, seen.size, "1 tentativa + 2 novas"
    assert_equal 1, seen.uniq.size, "mesmo X-Request-Id em todas as tentativas"
    assert_equal seen.first, error.request_id
  ensure
    server&.close
  end

  def test_timeout_vira_network_error
    silent = TCPServer.new("127.0.0.1", 0) # aceita (backlog) e nunca responde
    begin
      bz = Bzapper::Client.new("bz_live_unit", base_url: "http://127.0.0.1:#{silent.addr[1]}", max_retries: 0)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      assert_raises(Bzapper::NetworkError) { bz.system.get_health(timeout: 0.3) }
      assert_operator Process.clock_gettime(Process::CLOCK_MONOTONIC) - started, :<, 5
    ensure
      silent.close
    end
  end
end

class IdempotencyTest < ServerTestCase
  SENT = { "status" => "queued" }.freeze

  def test_chave_do_usuario_vai_como_veio_em_todas_as_tentativas
    bz = client([fail_with(503, "unavailable"), ok(SENT, status: 202)])
    assert_equal SENT, bz.messages.send_text(to: "5511999990000", body: "oi", idempotency_key: "pedido-4471")
    assert_equal %w[pedido-4471 pedido-4471], requests.map { |r| r[:headers]["idempotency-key"] }
    assert_equal 1, requests.map { |r| r[:headers]["x-request-id"] }.uniq.size
  end

  def test_chave_gerada_por_chamada_e_so_em_escrita
    bz = client([ok(SENT, status: 202), ok(SENT, status: 202), ok({ "data" => [] })])
    bz.messages.send_text(to: "5511999990000", body: "a")
    bz.messages.send_text(to: "5511999990000", body: "b")
    bz.instances.list_instances
    first, second, get = requests
    refute_empty first[:headers]["idempotency-key"]
    refute_equal first[:headers]["idempotency-key"], second[:headers]["idempotency-key"]
    refute get[:headers].key?("idempotency-key")
    refute_equal first[:headers]["x-request-id"], second[:headers]["x-request-id"]
  end

  def test_chave_vazia_vira_gerada
    bz = client([ok(SENT, status: 202)])
    bz.messages.send_text(to: "5511999990000", body: "a", idempotency_key: "")
    assert_match(/\A\h{8}-/, requests.first[:headers]["idempotency-key"])
  end
end

class RetryTest < ServerTestCase
  def test_backoff_exponencial_com_jitter
    bz = client([fail_with(502, "bad_gateway"), fail_with(504, "timeout"), ok({})])
    bz.system.get_health
    assert_equal 3, requests.size
    assert_equal 2, @sleeps.size
    assert_operator @sleeps[0], :>=, 0.5
    assert_operator @sleeps[0], :<=, 0.625
    assert_operator @sleeps[1], :>=, 1.0
    assert_operator @sleeps[1], :<=, 1.25
  end

  def test_backoff_tem_teto_de_8s
    20.times { assert_operator Bzapper::Transport.backoff(10), :<=, 10.0 }
    assert_operator Bzapper::Transport.backoff(10), :>=, 8.0
  end

  def test_retry_after_tem_teto_de_60s
    bz = client([fail_with(429, "rate_limited", { "Retry-After" => "600" }), ok({})])
    bz.system.get_health
    assert_equal [60.0], @sleeps
  end

  def test_retry_after_em_data_http
    future = (Time.now + 30).httpdate
    bz = client([fail_with(503, "unavailable", { "Retry-After" => future }), ok({})])
    bz.system.get_health
    assert_operator @sleeps.first, :<=, 30
    assert_operator @sleeps.first, :>, 25
  end

  def test_500_e_4xx_nao_repetem
    [500, 400, 401, 404, 409, 422].each do |status|
      bz = client([fail_with(status, "x")])
      assert_raises(Bzapper::Error) { bz.system.get_health }
      assert_equal 1, requests.size, "status #{status}"
      assert_empty @sleeps
    end
  end

  def test_max_retries_zero
    bz = client([fail_with(503, "unavailable")], max_retries: 0)
    error = assert_raises(Bzapper::ServerError) { bz.system.get_health }
    assert_equal 503, error.status
    assert_equal 1, requests.size
  end

  def test_parse_retry_after
    assert_equal 1, Bzapper::Transport.parse_retry_after("1")
    assert_equal 1.5, Bzapper::Transport.parse_retry_after("1.5")
    assert_nil Bzapper::Transport.parse_retry_after("")
    assert_nil Bzapper::Transport.parse_retry_after("amanhã")
    assert_equal 0, Bzapper::Transport.parse_retry_after((Time.now - 60).httpdate)
  end
end

class EncodingTest < ServerTestCase
  def test_listas_de_query_viram_csv_e_datas_utc_z
    bz = client([ok({ "data" => [] })])
    bz.contacts.list_contacts(tags: %w[vip lead], groups: ["a b"], has_email: false,
                              created_after: Time.new(2026, 9, 1, 0, 0, 0, "-03:00"), search: nil)
    record = requests.first
    assert_equal [["created_after", "2026-09-01T03:00:00Z"], ["groups", "a b"], ["has_email", "false"],
                  ["tags", "vip,lead"]], record[:query].sort
    assert_includes record[:raw_query], "groups=a%20b"
    refute_includes record[:raw_query], "search"
  end

  def test_omitido_x_null
    bz = client([ok({}), ok({})])
    bz.contacts.update_contact("c1", name: "Ana")
    bz.contacts.update_contact("c1", email: nil)
    assert_equal({ "name" => "Ana" }, json_body(requests[0]))
    assert_equal({ "email" => nil }, json_body(requests[1]))
  end

  def test_corpo_aninhado_com_simbolos_e_datas
    bz = client([ok({ "status" => "scheduled" }, status: 202)])
    bz.messages.send_image(to: "5511999990000", media: { url: "https://x/y.png", caption: "olá" },
                           scheduled_at: Time.utc(2026, 9, 21, 12))
    assert_equal({ "to" => "5511999990000", "media" => { "url" => "https://x/y.png", "caption" => "olá" },
                   "scheduled_at" => "2026-09-21T12:00:00Z" }, json_body(requests.first))
    assert_equal "application/json", requests.first[:headers]["content-type"]
  end

  def test_caminho_codificado_por_segmento_e_jid_como_veio
    bz = client([ok({}), ok({})])
    bz.instances.get_instance("a/b c")
    bz.groups.get_group("120363000000000000@g.us", instance_id: "i1")
    assert_equal "/instances/a%2Fb%20c", requests[0][:path]
    assert_equal "/groups/120363000000000000%40g.us", requests[1][:path]
  end

  def test_caminho_invalido_sem_requisicao
    bz = client([])
    ["", ".", "..", nil].each do |bad|
      assert_raises(ArgumentError) { bz.instances.get_instance(bad) }
    end
    assert_empty requests
  end

  def test_post_sem_corpo_vai_com_content_length_zero
    bz = client([ok({})])
    bz.instances.disconnect_instance("i1")
    record = requests.first
    assert_equal "", record[:body]
    assert_equal "0", record[:headers]["content-length"]
    refute record[:headers].key?("content-type")
  end

  def test_base_url_com_prefixo_e_barra_final
    server.reset([ok({})])
    bz = Bzapper::Client.new("bz_live_unit", base_url: "#{server.base_url}/v1/")
    bz.system.get_health
    assert_equal "/v1/healthz", requests.first[:path]
  end

  def test_locale_e_projeto_viram_headers
    bz = client([ok({ "data" => [] })], locale: "en-US", project_id: "p1")
    bz.instances.list_instances
    headers = requests.first[:headers]
    assert_equal "en-US", headers["accept-language"]
    assert_equal "p1", headers["x-project-id"]
  end

  def test_sem_locale_nem_projeto_sem_headers
    bz = client([ok({ "data" => [] })])
    bz.instances.list_instances
    refute requests.first[:headers].key?("accept-language")
    refute requests.first[:headers].key?("x-project-id")
  end

  def test_timeout_por_chamada_invalido
    bz = client([])
    assert_raises(ArgumentError) { bz.system.get_health(timeout: 0) }
    assert_empty requests
  end
end

class UploadTest < ServerTestCase
  def test_bytes
    bz = client([ok({ "logo_url" => "https://cdn/x.png" })])
    result = bz.accounts.upload_brand_logo(file: "\x89PNG".b, filename: "logo.png", content_type: "image/png")
    assert_equal({ "logo_url" => "https://cdn/x.png" }, result)
    record = requests.first
    assert_match %r{\Amultipart/form-data; boundary=bzapper-\h{32}\z}, record[:headers]["content-type"]
    assert_includes record[:body], "name=\"file\"; filename=\"logo.png\""
    assert_includes record[:body], "Content-Type: image/png"
    assert_includes record[:body], "\x89PNG".b
    refute_empty record[:headers]["idempotency-key"]
  end

  def test_caminho_no_disco_e_io
    Tempfile.create(["banner", ".jpg"]) do |file|
      file.binmode
      file.write("JPEGDATA")
      file.flush
      bz = client([ok({}), ok({})])
      bz.campaigns.upload_campaign_media(file: Pathname.new(file.path))
      bz.accounts.upload_project_logo("p1", file: StringIO.new("IO!"), filename: "x.bin")
      assert_includes requests[0][:body], "filename=\"#{File.basename(file.path)}\""
      assert_includes requests[0][:body], "Content-Type: application/octet-stream"
      assert_includes requests[0][:body], "JPEGDATA"
      assert_equal "/projects/p1/logo", requests[1][:path]
      assert_includes requests[1][:body], "IO!"
    end
  end

  def test_mesmos_bytes_na_nova_tentativa
    bz = client([fail_with(502, "bad_gateway"), ok({})])
    bz.accounts.upload_brand_logo(file: "abc", filename: "a.txt")
    assert_equal requests[0][:body], requests[1][:body]
  end

  def test_argumentos_invalidos
    bz = client([])
    assert_raises(ArgumentError) { bz.accounts.upload_brand_logo(file: nil) }
    assert_raises(TypeError) { bz.accounts.upload_brand_logo(file: 42) }
    assert_raises(ArgumentError) { bz.accounts.upload_brand_logo(file: "x", filename: "a\"b") }
    assert_empty requests
  end
end

class ResponseAndErrorTest < ServerTestCase
  def test_devolve_o_objeto_inteiro_sem_desembrulhar_data
    body = { "data" => [{ "id" => "i1", "campo_novo" => 1 }], "total" => 1 }
    bz = client([ok(body)])
    assert_equal body, bz.instances.list_instances
  end

  def test_204_e_corpo_vazio_viram_nil
    bz = client([{ "status" => 204, "headers" => {}, "body" => nil }, ok(nil)])
    assert_nil bz.webhooks.delete_webhook("w1")
    assert_nil bz.accounts.list_my_keys
  end

  def test_2xx_nao_json_e_invalid_response
    bz = client([ok("<html>proxy</html>")])
    error = assert_raises(Bzapper::Error) { bz.system.get_health }
    assert_instance_of Bzapper::Error, error
    assert_equal ["INVALID_RESPONSE", 200], [error.code, error.status]
    assert_equal requests.first[:headers]["x-request-id"], error.request_id
  end

  def test_campos_do_erro
    bz = client([fail_with(403, "insufficient_scope", { "X-Required-Scope" => "messages:send",
                                                        "X-Request-Id" => "req-9" },
                           message: "Escopo insuficiente")])
    error = assert_raises(Bzapper::PermissionDeniedError) { bz.messages.send_text(to: "1", body: "x") }
    assert_equal "insufficient_scope", error.code
    assert_equal "Escopo insuficiente", error.message
    assert_equal 403, error.status
    assert_equal 403, error.status_code
    assert_equal "req-9", error.request_id
    assert_equal "messages:send", error.required_scope
    assert_equal "pt-BR", error.locale
    assert_equal "insufficient_scope", error.body["code"]
    assert_nil error.retry_after
    detailed = error.detailed_message
    %w[insufficient_scope 403 messages:send req-9].each { |part| assert_includes detailed, part }
  end

  def test_code_cai_para_error_e_depois_para_http_status
    bz = client([
                  { "status" => 409, "headers" => {}, "body" => { "error" => "busy" } },
                  { "status" => 418, "headers" => {}, "body" => "teapot" }
                ])
    error = assert_raises(Bzapper::ConflictError) { bz.system.get_health }
    assert_equal "busy", error.code
    assert_equal "busy", error.message
    error = assert_raises(Bzapper::Error) { bz.system.get_health }
    assert_instance_of Bzapper::Error, error
    assert_equal "HTTP_418", error.code
    assert_equal requests.last[:headers]["x-request-id"], error.request_id
  end

  def test_retry_after_so_em_429
    bz = client([fail_with(429, "rate_limited", { "Retry-After" => "7" })], max_retries: 0)
    error = assert_raises(Bzapper::RateLimitError) { bz.system.get_health }
    assert_equal 7, error.retry_after
  end

  def test_classe_por_status
    {
      400 => Bzapper::ValidationError, 401 => Bzapper::AuthenticationError,
      403 => Bzapper::PermissionDeniedError, 404 => Bzapper::NotFoundError,
      409 => Bzapper::ConflictError, 422 => Bzapper::ValidationError, 429 => Bzapper::RateLimitError,
      500 => Bzapper::ServerError, 503 => Bzapper::ServerError, 402 => Bzapper::Error
    }.each { |status, klass| assert_equal klass, Bzapper::Error.class_for(status), status }
    [Bzapper::AuthenticationError, Bzapper::PermissionDeniedError, Bzapper::NotFoundError,
     Bzapper::ConflictError, Bzapper::ValidationError, Bzapper::RateLimitError, Bzapper::ServerError,
     Bzapper::NetworkError].each { |klass| assert_operator klass, :<, Bzapper::Error }
    assert_same Bzapper::Error, Bzapper::BzapperError
  end
end

class ClientTest < Minitest::Test
  def test_chave_vazia_e_erro_de_argumento
    assert_raises(ArgumentError) { Bzapper::Client.new("") }
    assert_raises(ArgumentError) { Bzapper::Client.new("   ") }
    assert_raises(TypeError) { Bzapper::Client.new(nil) }
    assert_raises(ArgumentError) { Bzapper::PartnerClient.new("") }
    refute_kind_of Bzapper::Error, (Bzapper::Client.new("") rescue $!) # rubocop:disable Style/RescueModifier
  end

  def test_padroes_e_sem_rede_na_construcao
    bz = Bzapper::Client.new("bz_live_abcdefghijkl")
    assert_equal "https://api.bzapper.com.br", bz.base_url
    assert_equal 30, bz.timeout
    assert_equal 2, bz.max_retries
    refute_includes bz.inspect, "abcdefghijkl", "inspect não vaza a chave"
  end

  def test_opcoes_invalidas
    assert_raises(ArgumentError) { Bzapper::Client.new("k", max_retries: -1) }
    assert_raises(ArgumentError) { Bzapper::Client.new("k", timeout: 0) }
    assert_raises(ArgumentError) { Bzapper::Client.new("k", base_url: "ftp://x") }
    assert_raises(ArgumentError) { Bzapper::Client.new("k", sleeper: 1) }
  end

  def test_recursos
    bz = Bzapper::Client.new("k")
    Bzapper::ResourceAccessors::RESOURCES.each do |name|
      assert_kind_of Bzapper::Resources::Base, bz.public_send(name), name
    end
    assert_respond_to bz.messages, :send_text
    assert_respond_to bz.instances, :connect_instance
  end

  def test_unset
    assert_same Bzapper::UNSET, Bzapper::UNSET.dup
    assert_equal "Bzapper::UNSET", Bzapper::UNSET.inspect
  end
end

class PartnerTest < ServerTestCase
  def test_parceiro_usa_o_mesmo_transporte
    bz = partner([ok({ "api_key" => "bz_live_x" })])
    result = bz.exchange_connect_code(code: "c1")
    assert_equal "bz_live_x", result["api_key"]
    record = requests.first
    assert_equal "/partner/connect/exchange", record[:path]
    assert_equal "Bearer bz_partner_unit", record[:headers]["authorization"]
    assert_equal "bzapper-ruby/#{Bzapper::VERSION}", record[:headers]["x-bzapper-client"]
  end
end

class WebhookTest < Minitest::Test
  SECRET = "whsec_unit"
  BODY = '{"event_id":"e1","event_type":"message.received","instance_id":"i1",' \
         '"sender":{"jid":"5511@s.whatsapp.net","name":"Ana"},"payload":{"body":"olá"},"novo":1}'

  def test_construct_event
    signature = Bzapper::Webhook.sign(SECRET, BODY)
    event = Bzapper::Webhook.construct_event(SECRET, BODY, signature)
    assert_equal "e1", event.id
    assert_equal "message.received", event.type
    assert_equal "i1", event.instance_id
    assert_equal "Ana", event.sender["name"]
    assert_equal "olá", event.payload["body"]
    assert_equal 1, event["novo"], "campos desconhecidos preservados"
    assert_equal [], event.mentions
  end

  def test_assinatura_invalida
    refute Bzapper::Webhook.verify(SECRET, BODY, nil)
    refute Bzapper::Webhook.verify(SECRET, BODY, "sha256=zz")
    refute Bzapper::Webhook.verify("", BODY, Bzapper::Webhook.sign(SECRET, BODY))
    assert_raises(ArgumentError) { Bzapper::Webhook.sign("", BODY) }
    assert_raises(Bzapper::SignatureError) { Bzapper::Webhook.construct_event(SECRET, BODY, "sha256=00") }
  end

  def test_router
    router = Bzapper::Webhook::Router.new(SECRET)
    seen = []
    router.on("message.received") { |event| seen << [:typed, event.id] }
    router.on("instance.banned") { |_event| seen << :never }
    router.on_any { |event| seen << [:any, event.type] }
    event = router.handle(BODY, Bzapper::Webhook.sign(SECRET, BODY))
    assert_equal "e1", event.id
    assert_equal [[:typed, "e1"], [:any, "message.received"]], seen
    assert_raises(Bzapper::SignatureError) { router.handle(BODY, "sha256=00") }
  end
end
