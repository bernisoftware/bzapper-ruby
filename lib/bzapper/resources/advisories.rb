# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Avisos "atualize sua integração" — `client.advisories`.
    class Advisories < Base
      # List pending integration advisories. `GET /advisories`
      #
      # Advisories that affect THIS account and have not been dismissed. Use `action` — it states
      # exactly what to do. Automate with the `advisory.published` webhook.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_advisories(timeout: nil)
        request("GET", "/advisories", timeout: timeout)
      end

      # Dismiss an advisory. `POST /advisories/{id}/read`
      #
      # Marks the advisory as handled; it stops being returned by `GET /advisories`.
      #
      # @param id [String] Advisory ID.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def mark_advisory_read(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/advisories/#{segment(id, "id")}/read",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
