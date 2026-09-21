# frozen_string_literal: true

module Bzapper
  # Recursos da API (um por tag da spec): `client.messages`, `client.instances`,
  # `client.groups`, `client.contacts`, `client.campaigns`, `client.webhooks`…
  #
  # Convenções (iguais em todos os métodos, gerados de `openapi.yaml`):
  #
  # * Nome do método = `operationId` em snake_case (`sendText` → `send_text`).
  # * Parâmetros de caminho são posicionais; query e corpo são keyword args.
  # * Obrigatórios da spec não têm padrão (faltou → `ArgumentError` do Ruby).
  # * Campos de corpo opcionais têm padrão {Bzapper::UNSET} — não informado = não enviado.
  #   `nil` explícito vai como `null` (limpa o campo num PATCH).
  # * Filtros de query com `nil` são omitidos; listas vão como CSV; `Time` vira ISO 8601 UTC.
  # * Toda chamada aceita `timeout:` (segundos, por tentativa); as escritas aceitam
  #   `idempotency_key:` (senão a SDK gera uma e a repete nas novas tentativas).
  # * O retorno é o JSON inteiro da resposta (`Hash`/`Array` com chaves **string**; `{"data"
  #   => [...]}` NÃO é desembrulhado, para preservar paginação/metadados). 204 → `nil`.
  module Resources
    # Encanamento comum de {Base} e {Bzapper::PartnerClient}.
    # @api private
    module Requests
      private

      def request(method, path, query: nil, body: nil, multipart: nil, idempotency_key: nil, timeout: nil)
        @transport.request(method, path, query: query, body: body, multipart: multipart,
                                         idempotency_key: idempotency_key, timeout: timeout)
      end

      def segment(value, name)
        Codec.path_segment(value, name)
      end

      def compact(fields)
        Codec.compact(fields)
      end

      def upload(field, file, filename, content_type)
        Upload.new(field, file, filename: filename, content_type: content_type)
      end
    end

    # @api private
    class Base
      include Requests

      def initialize(transport)
        @transport = transport
      end

      def inspect
        "#<#{self.class.name}>"
      end
    end
  end
end
