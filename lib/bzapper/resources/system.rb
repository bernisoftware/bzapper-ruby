# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Saúde e meta — `client.system`.
    class System < Base
      # Health check. `GET /healthz`
      #
      # Service liveness/readiness. No authentication.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_health(timeout: nil)
        request("GET", "/healthz", timeout: timeout)
      end
    end
  end
end
