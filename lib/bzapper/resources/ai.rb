# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Conector de IA (MCP): apps de IA autorizados a operar a conta e revogação do acesso — `client.ai`.
    class Ai < Base
      # AI apps connected to this account (MCP connector). `GET /ai-connections`
      #
      # Active connections of the AI connector. An admin sees every connection of the account; an
      # agent sees only their own. An API key without a person behind it sees them only if it is an
      # admin key.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_ai_connections(timeout: nil)
        request("GET", "/ai-connections", timeout: timeout)
      end

      # Revoke an AI app's access. Its tokens stop working on the next call. `DELETE
      # /ai-connections/{id}`
      #
      # An admin can revoke any connection of the account; an agent, only their own.
      #
      # @param id [String] Connection ID.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def revoke_ai_connection(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/ai-connections/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
