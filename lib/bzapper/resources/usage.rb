# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Uso medido (consumo) — `client.usage`.
    class Usage < Base
      # AGGREGATE account usage + per project (admin). `GET /account/usage`
      #
      # Billing basis — sums all projects and breaks it down per project.
      #
      # @param from [Time, String, nil] (query)
      # @param to [Time, String, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_account_usage(from: nil, to: nil, timeout: nil)
        query = {
          "from" => from,
          "to" => to
        }
        request("GET", "/account/usage", query: query, timeout: timeout)
      end

      # Tenant usage summary (by period/type/number). `GET /usage`
      #
      # @param from [Time, String, nil] (query)
      # @param to [Time, String, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_usage(from: nil, to: nil, timeout: nil)
        query = {
          "from" => from,
          "to" => to
        }
        request("GET", "/usage", query: query, timeout: timeout)
      end
    end
  end
end
