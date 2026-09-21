# frozen_string_literal: true

# Conformidade: roda TODOS os casos de `test/fixtures/conformance/cases.json` (BRIEF §7).
#
# Para cada caso, o servidor HTTP local confere cada troca — método, caminho (segmento a
# segmento, decodificado; o cru sem espaço), query, corpo JSON (ou multipart), `Authorization`,
# `X-Bzapper-Client`, `X-Request-Id`, `Idempotency-Key` — e, entre novas tentativas da mesma
# chamada, que os ids se repetem (chamada nova → ids novos). Depois compara o retorno (ou o
# erro) com `expect`.
#
# Endpoint novo sem método na SDK quebra este teste: todo op de `ops` precisa estar em
# `Conformance::OPS` (test/support/ops_table.rb, gerado por script/generate.rb).

require "test_helper"
require_relative "support/ops_table"

module Conformance
  CASES = TestSupport.cases
  API_KEY = CASES.fetch("api_key")
  EXCLUDED = CASES.fetch("sdk_excluded_ops", []).freeze
  CLIENT_RE = %r{\Abzapper-ruby/#{Regexp.escape(Bzapper::VERSION)}\z}.freeze
  REQUEST_ID_RE = /\A[0-9a-f]{32}\z/.freeze
  WRITES = %w[POST PUT PATCH DELETE].freeze
  SENT = "$sent" # em expect.error.request_id: "o X-Request-Id que a SDK enviou"

  ERROR_TYPES = {
    "authentication" => Bzapper::AuthenticationError,
    "permission_denied" => Bzapper::PermissionDeniedError,
    "not_found" => Bzapper::NotFoundError,
    "conflict" => Bzapper::ConflictError,
    "validation" => Bzapper::ValidationError,
    "rate_limit" => Bzapper::RateLimitError,
    "server" => Bzapper::ServerError,
    "network" => Bzapper::NetworkError,
    "api" => Bzapper::Error
  }.freeze

  module_function

  # `args` neutros → chamada idiomática: parâmetros de caminho posicionais (pelo nome), query e
  # corpo como keyword args; multipart vira `file:` (bytes) + `filename:` + `content_type:`.
  # Argumento que o método não conhece estoura ArgumentError do Ruby.
  def invoke(method, kase)
    args = Marshal.load(Marshal.dump(kase.fetch("args")))
    path = args.fetch("path")
    keywords = {}
    keywords.merge!(args.fetch("query"))
    body = args["body"]
    if kase["multipart"]
      file = body.fetch("file")
      keywords["file"] = file.fetch("content_base64").unpack1("m")
      keywords["filename"] = file.fetch("filename")
      keywords["content_type"] = file.fetch("content_type")
      keywords.merge!(body.fetch("fields"))
    elsif body
      raise "corpo que não é objeto: #{body.inspect}" unless body.is_a?(Hash)

      keywords.merge!(body)
    end
    (kase["options"] || {}).each { |name, value| keywords[name] = value }

    positional = []
    method.parameters.each do |kind, name|
      next unless kind == :req
      raise ArgumentError, "caso sem o parâmetro de caminho #{name}" unless path.key?(name.to_s)

      positional << path.fetch(name.to_s)
    end
    extra = path.keys - method.parameters.select { |kind, _| kind == :req }.map { |_, name| name.to_s }
    raise "parâmetros de caminho sem posicional no método: #{extra}" unless extra.empty?

    method.call(*positional, **keywords.transform_keys(&:to_sym))
  end

  # Percent-decode de um segmento (sem tratar `+` como espaço).
  def unescape(segment)
    segment.b.gsub(/%\h\h/) { |hex| hex[1, 2].to_i(16).chr }.force_encoding(Encoding::UTF_8)
  end

  def segments(path)
    path.split("/", -1).map { |seg| unescape(seg) }
  end

  # Forma canônica: distingue `1` de `1.0` e ignora a ordem das chaves.
  def canonical(value)
    JSON.generate(sort_keys(value))
  end

  def sort_keys(value)
    case value
    when Hash then value.keys.sort.to_h { |key| [key, sort_keys(value[key])] }
    when Array then value.map { |item| sort_keys(item) }
    else value
    end
  end
end

class ConformanceTest < Minitest::Test
  include Conformance

  def assert_json_equal(expected, actual, what)
    return assert_nil(actual, what) if expected.nil?

    assert_equal expected, actual, what
    assert_equal Conformance.canonical(expected), Conformance.canonical(actual), "#{what} (tipos JSON)"
  end

  def run_case(kase)
    op = kase.fetch("op")
    assert OPS.key?(op), "op #{op.inspect} sem método na SDK (Conformance::OPS)"

    exchanges = kase.fetch("exchanges")
    server = TestSupport.server
    server.reset(exchanges.map { |exchange| exchange["response"] })
    sleeps = []
    sleeper = ->(s) { sleeps << s }
    options = { base_url: server.base_url, max_retries: CASES.fetch("max_retries"), sleeper: sleeper }
    client = Bzapper::Client.new(API_KEY, **options)
    partner = Bzapper::PartnerClient.new(API_KEY, **options)

    result = nil
    error = nil
    begin
      result = Conformance.invoke(OPS.fetch(op).call(client, partner), kase)
    rescue Bzapper::Error, ArgumentError => e
      error = e
    end

    sent = server.requests
    assert_empty server.errors, "erros no servidor falso"
    check_exchanges(kase, exchanges, sent)
    assert_equal exchanges.count { |exchange| exchange["retry"] }, sleeps.size,
                 "uma espera (desligada) por nova tentativa"

    expect = kase.fetch("expect")
    if expect.key?("error")
      check_error(expect["error"], error, result, sent)
    else
      assert_nil error, "erro inesperado: #{error.inspect} #{error&.message}"
      assert_json_equal expect["result"], result, "resultado"
    end
  end

  def check_error(want, error, result, sent)
    refute_nil error, "esperava erro #{want['type']}, veio #{result.inspect}"
    if want["type"] == "argument"
      assert_kind_of ArgumentError, error
      refute_kind_of Bzapper::Error, error
      # Tem que ser a validação da SDK, não um ArgumentError de assinatura do Ruby.
      assert error.backtrace.first.include?("bzapper/codec.rb"),
             "ArgumentError fora da validação da SDK: #{error.message}"
      assert_empty sent, "erro de argumento não pode fazer requisição"
      return
    end

    raise error if error.is_a?(ArgumentError)

    assert_instance_of ERROR_TYPES.fetch(want.fetch("type")), error
    assert_equal want["code"], error.code
    assert_equal want["status"], error.status
    if want.key?("request_id")
      expected_id = want["request_id"]
      if expected_id == SENT
        expected_id = sent.last[:headers]["x-request-id"]
        refute_nil expected_id
      end
      assert_equal expected_id, error.request_id
    end
    assert_equal want["retry_after"], error.retry_after if want.key?("retry_after")
    assert_equal want["required_scope"], error.required_scope if want.key?("required_scope")
  end

  def check_query(want, got, where)
    expected = want.map { |key, value| [key, value] }
    assert_equal expected.sort, got.sort, "#{where}: query"
    assert_equal got.map(&:first).uniq.size, got.size, "#{where}: parâmetro de query repetido"
  end

  def check_exchanges(kase, exchanges, sent)
    assert_equal exchanges.size, sent.size,
                 "nº de requisições: #{sent.map { |r| "#{r[:method]} #{r[:path]}" }.join(', ')}"
    previous = nil
    exchanges.zip(sent).each_with_index do |(exchange, got), index|
      want = exchange.fetch("request")
      where = "#{kase['id']} troca #{index}"
      headers = got[:headers]

      assert_equal want["method"], got[:method], "#{where}: método"
      refute_includes got[:path], " ", "#{where}: caminho cru com espaço"
      assert_equal Conformance.segments(want["path"]), Conformance.segments(got[:path]),
                   "#{where}: caminho (#{got[:path]})"
      check_query(want["query"] || {}, got[:query], where)

      if kase["multipart"]
        assert_match %r{\Amultipart/form-data; boundary=}, headers["content-type"].to_s, "#{where}: Content-Type"
        filename = kase.dig("args", "body", "file", "filename")
        assert_includes got[:body], "filename=\"#{filename}\"", "#{where}: nome do arquivo no corpo"
        assert_includes got[:body], kase.dig("args", "body", "file", "content_base64").unpack1("m").b
      elsif want["body"].nil?
        assert_equal "", got[:body], "#{where}: não devia ter corpo"
        refute headers.key?("content-type"), "#{where}: Content-Type sem corpo"
      else
        assert_equal "application/json", headers["content-type"], "#{where}: Content-Type"
        body = JSON.parse(got[:body].dup.force_encoding(Encoding::UTF_8))
        assert_json_equal want["body"], body, "#{where}: corpo"
      end

      assert_equal "Bearer #{API_KEY}", headers["authorization"], "#{where}: Authorization"
      assert_equal "application/json", headers["accept"], "#{where}: Accept"
      assert_match CLIENT_RE, headers["x-bzapper-client"].to_s, "#{where}: X-Bzapper-Client"
      assert_equal headers["x-bzapper-client"], headers["user-agent"], "#{where}: User-Agent"
      assert_match REQUEST_ID_RE, headers["x-request-id"].to_s, "#{where}: X-Request-Id"
      if WRITES.include?(want["method"])
        refute_empty headers["idempotency-key"].to_s, "#{where}: Idempotency-Key"
      else
        refute headers.key?("idempotency-key"), "#{where}: Idempotency-Key em GET"
      end
      (want["headers"] || {}).each do |name, value|
        assert_equal value, headers[name.downcase], "#{where}: header #{name}"
      end

      assert exchange.key?("retry"), "#{where}: troca sem o campo 'retry'"
      if index.zero?
        refute exchange["retry"], "a 1ª troca não pode ser nova tentativa"
      elsif exchange["retry"]
        # nova tentativa da MESMA chamada: ids repetidos
        assert_equal previous["x-request-id"], headers["x-request-id"], "#{where}: X-Request-Id da nova tentativa"
        if WRITES.include?(want["method"])
          assert_equal previous["idempotency-key"], headers["idempotency-key"],
                       "#{where}: Idempotency-Key da nova tentativa"
        end
      else
        # chamada lógica nova: ids novos
        refute_equal previous["x-request-id"], headers["x-request-id"],
                     "#{where}: chamada nova precisa de X-Request-Id novo"
        if headers.key?("idempotency-key")
          refute_equal previous["idempotency-key"], headers["idempotency-key"],
                       "#{where}: chamada nova precisa de Idempotency-Key nova"
        end
      end
      previous = headers
    end
  end

  seen = {}
  Conformance::CASES.fetch("cases").each do |kase|
    name = "test_case_#{kase.fetch('id').gsub('.', 'dot').gsub(/\W+/, '_').gsub(/\A_+|_+\z/, '')}"
    raise "id de caso duplicado: #{kase['id']}" if seen.key?(name)

    seen[name] = true
    define_method(name) { run_case(kase) }
  end
end

class ConformanceCoverageTest < Minitest::Test
  include Conformance

  def test_os_casos_foram_carregados
    assert_operator CASES.fetch("cases").size, :>=, 181
    assert_equal 159, CASES.fetch("ops").size
    assert_equal 2, CASES.fetch("max_retries")
  end

  # Op de `ops` sem linha na tabela FALHA (não é pulado).
  def test_todo_op_tem_metodo
    assert_equal [], (CASES.fetch("ops") - OPS.keys).sort, "ops sem método na SDK — implemente"
    assert_equal [], (OPS.keys - CASES.fetch("ops")).sort, "linhas da tabela que não são ops dos casos"
  end

  def test_todo_op_tem_caso_basico
    ids = CASES.fetch("cases").map { |kase| kase["id"] }
    assert_equal [], CASES.fetch("ops").reject { |op| ids.include?("#{op}/basic") }
  end

  def test_cada_linha_da_tabela_resolve_para_um_metodo
    client = Bzapper::Client.new(API_KEY)
    partner = Bzapper::PartnerClient.new(API_KEY)
    OPS.each do |op, row|
      assert_kind_of Method, row.call(client, partner), op
    end
  end

  def test_op_desconhecido_falha
    fake = { "id" => "x/y", "op" => "naoExiste", "args" => { "path" => {}, "query" => {}, "body" => nil },
             "multipart" => false, "exchanges" => [], "expect" => { "result" => nil } }
    error = assert_raises(Minitest::Assertion) { ConformanceTest.new("probe").run_case(fake) }
    assert_includes error.message, "naoExiste"
  end

  def test_excluidos_nao_estao_na_sdk
    assert_equal [], (EXCLUDED & OPS.keys)
    client = Bzapper::Client.new(API_KEY)
    partner = Bzapper::PartnerClient.new(API_KEY)
    methods = Bzapper::ResourceAccessors::RESOURCES.flat_map { |r| client.public_send(r).public_methods(false) }
    methods += partner.public_methods
    EXCLUDED.each do |op|
      snake = op.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase.to_sym
      refute_includes methods, snake, "#{op} está em sdk_excluded_ops e não entra na SDK"
    end
  end

  def test_parceiro_nao_herda_metodos_do_cliente
    partner = Bzapper::PartnerClient.new(API_KEY)
    refute partner.respond_to?(:messages)
    refute partner.respond_to?(:send_text)
    refute Bzapper::Client.new(API_KEY).respond_to?(:get_partner_me)
  end

  def test_copia_dos_casos_em_dia
    skip "fonte dos casos só existe no monorepo" unless File.file?(TestSupport::MONOREPO_CASES)

    assert File.binread(TestSupport::VENDORED_CASES) == File.binread(TestSupport::MONOREPO_CASES),
           "test/fixtures/conformance/cases.json desatualizado — rode " \
           "`python3 clients/conformance/generate.py` (ele escreve a cópia; não edite à mão)"
  end

  def test_metodos_gerados_em_dia_com_a_spec
    skip "openapi.yaml só existe no monorepo" unless File.file?(TestSupport::MONOREPO_SPEC)
    skip "rodando contra a gem instalada" if TestSupport::AGAINST_GEM

    script = File.join(TestSupport::ROOT, "script", "generate.rb")
    output = IO.popen([RbConfig.ruby, script, "--check"], err: %i[child out], &:read)
    assert $?.success?, "script/generate.rb --check: #{output}"
  end
end

class SignatureVectorsTest < Minitest::Test
  def test_vetores
    vectors = Conformance::CASES.fetch("signatures")
    refute_empty vectors
    vectors.each do |vector|
      got = Bzapper::Webhook.verify(vector["secret"], vector["body"], vector["signature"])
      assert_equal vector["valid"], got, "vetor #{vector['id']}"

      if vector["valid"]
        event = Bzapper::Webhook.construct_event(vector["secret"], vector["body"], vector["signature"])
        assert_equal JSON.parse(vector["body"]), event.raw
      else
        assert_raises(Bzapper::SignatureError, "vetor #{vector['id']}") do
          Bzapper::Webhook.construct_event(vector["secret"], vector["body"], vector["signature"])
        end
      end
    end
  end

  def test_corpo_em_bytes_da_o_mesmo_resultado
    vector = Conformance::CASES.fetch("signatures").find { |v| v["valid"] }
    assert Bzapper::Webhook.verify(vector["secret"], vector["body"].b, vector["signature"])
    assert_equal vector["signature"], Bzapper::Webhook.sign(vector["secret"], vector["body"])
  end
end
