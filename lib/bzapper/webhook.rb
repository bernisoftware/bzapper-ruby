# frozen_string_literal: true

module Bzapper
  # Recebimento de webhooks — local, sem rede.
  #
  # A API assina cada entrega com `X-Bzapper-Signature: sha256=<hex>`, onde o hex é
  # `HMAC-SHA256(secret, corpo_cru)`. Também manda `X-Bzapper-Event-Id` e
  # `X-Bzapper-Event-Type`. Verifique SEMPRE o corpo **cru** (os bytes recebidos), nunca o JSON
  # re-serializado.
  #
  # @example Rack/Rails
  #   raw = request.body.read
  #   event = Bzapper::Webhook.construct_event(ENV["BZAPPER_WEBHOOK_SECRET"], raw,
  #                                            request.get_header("HTTP_X_BZAPPER_SIGNATURE"))
  #   puts event.type, event.payload["body"]
  #
  # Idempotência: cada evento traz um `event.id` estável — guarde os ids processados e ignore
  # repetições (a API pode reentregar).
  module Webhook
    SIGNATURE_HEADER = "X-Bzapper-Signature"
    EVENT_ID_HEADER = "X-Bzapper-Event-Id"
    EVENT_TYPE_HEADER = "X-Bzapper-Event-Type"
    PREFIX = "sha256="

    # Tipos de evento que a API pode entregar (referência).
    EVENT_TYPES = %w[
      message.received message.sent message.delivered message.read message.failed
      instance.connected instance.disconnected instance.banned instance.logged_out
      instance.warming instance.status
      group.joined group.left group.participant_added group.participant_removed
      group.participant_promoted group.participant_demoted
      group.subject_changed group.description_changed
      connect.completed connect.suspended connect.resumed connect.revoked
    ].freeze

    # Ciclo de vida de uma conexão do bZapper Connect — só no webhook do PARCEIRO.
    CONNECT_EVENT_TYPES = %w[connect.completed connect.suspended connect.resumed connect.revoked].freeze

    module_function

    # Assinatura esperada para um corpo (`sha256=<hex>`).
    # @param secret [String] o segredo do webhook (devolvido uma vez por `create_webhook`).
    # @param raw_body [String] o corpo cru.
    # @return [String]
    # @raise [ArgumentError] segredo vazio.
    def sign(secret, raw_body)
      raise ArgumentError, "secret do webhook é obrigatório." if secret.nil? || secret.to_s.empty?

      PREFIX + OpenSSL::HMAC.hexdigest("SHA256", secret.to_s.b, raw_body.to_s.b)
    end

    # `true` sse a assinatura confere com o HMAC do corpo **cru**. Comparação em tempo constante.
    # @param secret [String]
    # @param raw_body [String] os bytes recebidos, exatamente.
    # @param signature [String, nil] o valor do header `X-Bzapper-Signature`.
    # @return [Boolean]
    def verify(secret, raw_body, signature)
      return false if secret.nil? || secret.to_s.empty?
      return false if signature.nil? || signature.to_s.empty?

      expected = sign(secret, raw_body)
      given = signature.to_s.strip.b
      return false unless given.bytesize == expected.bytesize

      OpenSSL.fixed_length_secure_compare(expected, given)
    end

    # Verifica a assinatura e decodifica o evento.
    # @return [Event]
    # @raise [Bzapper::SignatureError] assinatura ausente ou inválida — NÃO processe.
    # @raise [JSON::ParserError] corpo assinado que não é JSON.
    def construct_event(secret, raw_body, signature)
      raise SignatureError, "assinatura de webhook inválida" unless verify(secret, raw_body, signature)

      text = raw_body.to_s.dup.force_encoding(::Encoding::UTF_8)
      Event.new(JSON.parse(text))
    end

    # Evento de webhook decodificado (o envelope entregue). Campos desconhecidos continuam em
    # {#raw}.
    class Event
      # @return [Hash] o envelope inteiro, como veio.
      attr_reader :raw

      def initialize(raw)
        @raw = raw.is_a?(Hash) ? raw : {}
      end

      # @return [String] id estável do evento (use para idempotência).
      def id
        @raw["event_id"].to_s
      end

      # @return [String] tipo do evento (`message.received`, `instance.connected`…).
      def type
        @raw["event_type"].to_s
      end

      # @return [String, nil]
      def timestamp
        @raw["timestamp"]
      end

      # @return [String, nil]
      def instance_id
        @raw["instance_id"]
      end

      # @return [String, nil] a correlação que você mandou no envio.
      def client_reference
        @raw["client_reference"]
      end

      # @return [Hash, nil] `{"jid", "name"}` quando o evento aconteceu num grupo.
      def group
        @raw["group"].is_a?(Hash) ? @raw["group"] : nil
      end

      # @return [Hash, nil] `{"jid", "lid", "name", "phone"}` de quem enviou/disparou.
      def sender
        @raw["sender"].is_a?(Hash) ? @raw["sender"] : nil
      end

      # @return [Array<String>]
      def mentions
        Array(@raw["mentions"])
      end

      # @return [Hash] dados específicos do tipo de evento.
      def payload
        @raw["payload"].is_a?(Hash) ? @raw["payload"] : {}
      end

      # @return [Hash, nil] conexão do Connect (só no webhook do parceiro).
      def connection
        @raw["connection"].is_a?(Hash) ? @raw["connection"] : nil
      end

      # @return [Hash]
      def to_h
        @raw
      end

      def [](key)
        @raw[key.to_s]
      end

      def inspect
        "#<Bzapper::Webhook::Event id=#{id.inspect} type=#{type.inspect}>"
      end
    end

    # Verifica, decodifica e despacha entregas para handlers por tipo de evento.
    #
    # @example
    #   router = Bzapper::Webhook::Router.new(ENV.fetch("BZAPPER_WEBHOOK_SECRET"))
    #   router.on("message.received") { |event| puts event.payload["body"] }
    #   router.handle(raw_body, signature) # SignatureError se não confere
    class Router
      def initialize(secret)
        raise ArgumentError, "Bzapper::Webhook::Router: secret é obrigatório." if secret.nil? || secret.to_s.empty?

        @secret = secret
        @handlers = Hash.new { |hash, key| hash[key] = [] }
        @any = []
      end

      # Registra um handler para um tipo de evento.
      def on(event_type, callable = nil, &block)
        @handlers[event_type.to_s] << (callable || block || raise(ArgumentError, "handler ausente"))
        self
      end

      # Registra um handler para TODO evento.
      def on_any(callable = nil, &block)
        @any << (callable || block || raise(ArgumentError, "handler ausente"))
        self
      end

      # Verifica + decodifica + despacha. Devolve o evento.
      # @raise [Bzapper::SignatureError]
      def handle(raw_body, signature)
        event = Webhook.construct_event(@secret, raw_body, signature)
        @handlers.fetch(event.type, []).each { |handler| handler.call(event) }
        @any.each { |handler| handler.call(event) }
        event
      end

      def inspect
        "#<Bzapper::Webhook::Router>"
      end
    end
  end
end
