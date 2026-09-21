# frozen_string_literal: true

# bZapper — quickstart da SDK Ruby.
#
# Rodar:
#   gem install bzapper
#   BZAPPER_API_KEY=bz_live_... BZAPPER_TO=+5511999999999 ruby examples/quickstart.rb
#
# De dentro do repositório da SDK (sem instalar): ruby -Ilib examples/quickstart.rb
# Opcional: BZAPPER_BASE_URL=http://localhost:8080 para apontar para a API local.
# Sem BZAPPER_TO, só lista os números (nada é enviado).

require "bzapper"

api_key = ENV["BZAPPER_API_KEY"].to_s
if api_key.empty?
  warn "Defina BZAPPER_API_KEY (painel do bZapper → Chaves de API)."
  exit 2
end

# base_url vazio/nil cai no padrão (produção).
client = Bzapper::Client.new(api_key, base_url: ENV["BZAPPER_BASE_URL"])

begin
  # 1) Seus números e o status de cada um.
  instances = client.instances.list_instances
  (instances["data"] || []).each do |inst|
    puts "número #{inst['phone']} — #{inst['status']}"
  end

  # 2) Envio (só com BZAPPER_TO): o bZapper escolhe o número do pool. A chave de idempotência
  #    faz uma segunda execução com o mesmo valor devolver a mesma resposta, sem reenviar.
  to = ENV["BZAPPER_TO"].to_s
  unless to.empty?
    sent = client.messages.send_text(to: to, body: "Olá do bZapper (Ruby #{RUBY_VERSION})!",
                                     idempotency_key: "quickstart-#{Time.now.strftime('%Y%m%d%H%M')}")
    puts "mensagem #{sent['message_id']} — #{sent['status']}"
  end
rescue Bzapper::Error => e
  # Use e.code na lógica (estável); e.request_id vai para o suporte.
  warn "#{e.code} (HTTP #{e.status}): #{e.message} [request_id=#{e.request_id}]"
  exit 1
end
