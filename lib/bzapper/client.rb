# frozen_string_literal: true

module Bzapper
  # Validação e montagem do transporte, comum ao {Client} e ao {PartnerClient}.
  # @api private
  module ClientOptions
    private

    def build_transport(api_key, base_url:, timeout:, max_retries:, locale:, project_id:, sleeper:)
      label = self.class.name
      raise TypeError, "#{label}: api_key precisa ser String (ex.: \"bz_live_...\")." unless api_key.is_a?(String)
      raise ArgumentError, "#{label}: api_key é obrigatória (ex.: \"bz_live_...\")." if api_key.strip.empty?
      unless max_retries.is_a?(Integer) && max_retries >= 0
        raise ArgumentError, "#{label}: max_retries precisa ser um inteiro >= 0."
      end
      unless timeout.is_a?(Numeric) && timeout.positive?
        raise ArgumentError, "#{label}: timeout precisa ser > 0 (segundos)."
      end
      if !sleeper.nil? && !sleeper.respond_to?(:call)
        raise ArgumentError, "#{label}: sleeper precisa responder a #call(segundos)."
      end

      url = base_url.to_s.strip
      url = DEFAULT_BASE_URL if url.empty?
      @masked_key = api_key.length > 8 ? "#{api_key[0, 8]}..." : "..."
      Transport.new(api_key, base_url: url, timeout: timeout, max_retries: max_retries,
                             locale: locale, project_id: project_id, sleeper: sleeper)
    end

    public

    # @return [String] URL da API (sem barra final).
    def base_url
      @transport.base_url
    end

    # @return [Numeric] segundos por tentativa.
    def timeout
      @transport.timeout
    end

    # @return [Integer] novas tentativas além da primeira.
    def max_retries
      @transport.max_retries
    end

    def inspect
      "#<#{self.class.name} api_key=#{@masked_key.inspect} base_url=#{base_url.inspect}>"
    end
    alias to_s inspect
  end

  # Cliente da API do bZapper.
  #
  # Nada é chamado na rede ao construir. Pode ser compartilhado entre threads (cada tentativa
  # abre a própria conexão). Os métodos ficam nos recursos (um por tag da spec):
  # `messages`, `instances`, `groups`, `conversations`, `advanced`, `contacts`, `campaigns`,
  # `scheduling`, `pools`, `webhooks`, `advisories`, `usage`, `billing`, `accounts`, `connect`
  # e `system`.
  #
  # @example
  #   client = Bzapper::Client.new(ENV.fetch("BZAPPER_API_KEY"))
  #   client.messages.send_text(to: "5511999990000", body: "Olá!")
  class Client
    include ClientOptions
    include ResourceAccessors

    # @param api_key [String] chave de API (`bz_live_...`, painel → Chaves de API). Único
    #   argumento posicional e obrigatório.
    # @param base_url [String] URL da API, sem barra final. Padrão: produção
    #   (`https://api.bzapper.com.br`). Em dev: `http://localhost:8080`.
    # @param timeout [Numeric] segundos por tentativa (padrão 30).
    # @param max_retries [Integer] novas tentativas além da primeira em erro de rede/timeout,
    #   429, 502, 503 e 504 (padrão 2; `0` desliga).
    # @param locale [String, nil] enviado como `Accept-Language` (mensagens de erro traduzidas).
    # @param project_id [String, nil] enviado como `X-Project-Id` (escopo de projeto; a chave já
    #   traz o dela).
    # @param sleeper [#call, nil] espera entre tentativas, chamada com os segundos (padrão
    #   `Kernel#sleep`). Serve para testes não dormirem de verdade.
    # @raise [ArgumentError] chave vazia ou opção inválida.
    # @raise [TypeError] chave que não é String.
    def initialize(api_key, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT,
                   max_retries: DEFAULT_MAX_RETRIES, locale: nil, project_id: nil, sleeper: nil)
      @transport = build_transport(api_key, base_url: base_url, timeout: timeout,
                                            max_retries: max_retries, locale: locale,
                                            project_id: project_id, sleeper: sleeper)
      build_resources(@transport)
    end
  end

  # Cliente do **bZapper Connect** do lado do PARCEIRO (`/partner/*`): o software parceiro
  # deixa os clientes DELE assinarem o bZapper Pro e conectarem o WhatsApp sem sair do produto.
  #
  # Autentica com a chave de parceiro — guarde-a só no **backend**, nunca no navegador. Mesmas
  # opções, cabeçalhos, erros e novas tentativas do {Client}; os métodos (`get_partner_me`,
  # `create_connect_session`, `exchange_connect_code`, `list_partner_connections`,
  # `get_partner_connection`, `revoke_partner_connection`, `rotate_partner_connection_key`)
  # ficam direto nele.
  #
  # @example
  #   partner = Bzapper::PartnerClient.new(ENV.fetch("BZAPPER_PARTNER_KEY"))
  #   session = partner.create_connect_session(external_id: "cliente-42",
  #                                            customer: { name: "Ana", email: "ana@example.com" })
  #   # front: BzapperConnect.open({ session }) → `code`; backend:
  #   key = partner.exchange_connect_code(code: code)["api_key"]
  class PartnerClient
    include ClientOptions
    include Resources::Requests
    include Resources::PartnerOperations

    # Todos os status de uma conexão do Connect.
    CONNECTION_STATUSES = %w[pending_account pending_payment pending_number active suspended revoked].freeze

    # Mesmas opções do {Client#initialize}.
    def initialize(api_key, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT,
                   max_retries: DEFAULT_MAX_RETRIES, locale: nil, project_id: nil, sleeper: nil)
      @transport = build_transport(api_key, base_url: base_url, timeout: timeout,
                                            max_retries: max_retries, locale: locale,
                                            project_id: project_id, sleeper: sleeper)
    end
  end
end
