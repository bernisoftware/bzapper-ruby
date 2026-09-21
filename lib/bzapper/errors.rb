# frozen_string_literal: true

module Bzapper
  # Erro devolvido pela API do bZapper (ou de rede, em {NetworkError}).
  #
  # Toda resposta fora de 2xx vira um `Bzapper::Error` — ou a subclasse do status. **Use
  # {#code} na sua lógica**: ele é estável (`instance_not_connected`, `insufficient_scope`…).
  # O {#message} é o `message` do corpo — texto para humanos, traduzido conforme `locale:`, que
  # pode mudar (sem corpo JSON, é o próprio {#code}). {#detailed_message} junta código, status,
  # escopo exigido, `Retry-After` e `request_id` (é o que aparece num erro não tratado).
  #
  # Argumento inválido no seu código (chave vazia, parâmetro de caminho vazio/"."/"..") NÃO é
  # `Bzapper::Error`: é `ArgumentError`/`TypeError`, na hora, sem requisição.
  class Error < StandardError
    # @return [String] código estável: `body.code`, senão `body.error`, senão `HTTP_<status>`
    #   (corpo não-JSON); `INVALID_RESPONSE` quando um 2xx chega com corpo que não é JSON;
    #   `NETWORK_ERROR` em falha de rede.
    attr_reader :code
    # @return [Integer] status HTTP (`0` em erro de rede).
    attr_reader :status
    # @return [String, nil] header `X-Request-Id` da resposta, senão o `X-Request-Id` que a SDK
    #   enviou. Informe-o ao suporte.
    attr_reader :request_id
    # @return [Integer, Float, nil] segundos do header `Retry-After` (só em 429).
    attr_reader :retry_after
    # @return [String, nil] escopo que faltou na chave (header `X-Required-Scope`, só em 403).
    attr_reader :required_scope
    # @return [String, nil] idioma da mensagem (`body.locale`), quando veio.
    attr_reader :locale
    # @return [Hash, String, nil] corpo da resposta decodificado, ou o texto cru se não é JSON.
    attr_reader :body

    def initialize(message = nil, code: nil, status: 0, request_id: nil, retry_after: nil,
                   required_scope: nil, locale: nil, body: nil)
      @code = code
      @status = status
      @request_id = request_id
      @retry_after = retry_after
      @required_scope = required_scope
      @locale = locale
      @body = body
      super(message || code || self.class.name)
    end

    # Mensagem completa: `code (HTTP status): message — escopo… [request_id=…]`.
    # @return [String]
    def detailed_message(highlight: false, **_options) # rubocop:disable Lint/UnusedMethodArgument
      text = +"#{code} (HTTP #{status})"
      text << ": #{message}" unless message == code
      text << " — escopo exigido: #{required_scope}" if required_scope
      text << " — tente de novo em #{retry_after}s" unless retry_after.nil?
      text << " [request_id=#{request_id}]" if request_id
      text
    end

    # Alias do padrão Berni (`status_code` nas SDKs Python/PHP).
    # @return [Integer]
    def status_code
      status
    end

    def inspect
      "#<#{self.class.name} code=#{code.inspect} status=#{status.inspect} " \
        "request_id=#{request_id.inspect}>"
    end

    STATUS_CLASSES = {} # preenchido abaixo, depois das subclasses
    private_constant :STATUS_CLASSES

    # Classe de erro para um status HTTP (5xx → {ServerError}; sem classe própria → a base).
    # @param status [Integer]
    # @return [Class]
    def self.class_for(status)
      return STATUS_CLASSES[status] if STATUS_CLASSES.key?(status)
      return ServerError if status >= 500 && status <= 599

      Error
    end
  end

  # Nome da base no padrão Berni (`BzapperError` nas outras SDKs). É a MESMA classe.
  BzapperError = Error

  # 401 — chave ausente, inválida ou revogada (`connect_revoked` numa conexão Connect encerrada).
  class AuthenticationError < Error; end

  # 403 — sem permissão: papel insuficiente ou escopo faltando na chave ({#required_scope}).
  class PermissionDeniedError < Error; end

  # 404 — o recurso não existe (ou não é deste projeto).
  class NotFoundError < Error; end

  # 409 — o estado atual impede a operação.
  class ConflictError < Error; end

  # 400 e 422 — corpo ou parâmetro inválido.
  class ValidationError < Error; end

  # 429 — limite de requisições; {#retry_after} diz quanto esperar.
  class RateLimitError < Error; end

  # 5xx — erro do lado da API. Informe o {#request_id}.
  class ServerError < Error; end

  # Falha de conexão ou timeout (`status == 0`, `code == "NETWORK_ERROR"`).
  class NetworkError < Error
    def initialize(message = nil, request_id: nil, **_ignored)
      super(message || "NETWORK_ERROR", code: "NETWORK_ERROR", status: 0, request_id: request_id)
    end
  end

  class Error
    STATUS_CLASSES.merge!(
      400 => ValidationError,
      401 => AuthenticationError,
      403 => PermissionDeniedError,
      404 => NotFoundError,
      409 => ConflictError,
      422 => ValidationError,
      429 => RateLimitError
    ).freeze
  end

  # Assinatura de webhook ausente ou inválida ({Webhook.construct_event}). Não processe o evento.
  class SignatureError < StandardError; end
end
