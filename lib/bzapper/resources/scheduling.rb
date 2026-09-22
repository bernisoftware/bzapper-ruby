# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Envios agendados — `client.scheduling`.
    class Scheduling < Base
      # List scheduled sends. `GET /messages/scheduled`
      #
      # @param limit [Integer, nil] (query) Max items.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_scheduled(limit: nil, timeout: nil)
        query = {
          "limit" => limit
        }
        request("GET", "/messages/scheduled", query: query, timeout: timeout)
      end

      # Cancel a pending scheduled send. `DELETE /messages/scheduled/{id}`
      #
      # @param id [String] Scheduled message ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def cancel_scheduled(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/messages/scheduled/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
