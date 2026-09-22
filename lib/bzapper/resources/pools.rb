# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Pools de números (rotação) — `client.pools`.
    class Pools < Base
      # List the tenant's pools. `GET /pools`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_pools(timeout: nil)
        request("GET", "/pools", timeout: timeout)
      end

      # Create a number pool. `POST /pools`
      #
      # @param name [String, nil] (corpo)
      # @param strategy [String, nil] (corpo) Pool rotation strategy.
      # @param is_default [Boolean, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_pool(name: UNSET, strategy: UNSET, is_default: UNSET, idempotency_key: nil,
                      timeout: nil)
        payload = compact(
          "name" => name,
          "strategy" => strategy,
          "is_default" => is_default
        )
        request("POST", "/pools", body: payload, idempotency_key: idempotency_key, timeout: timeout)
      end

      # Get a pool (with members). `GET /pools/{id}`
      #
      # @param id [String] Pool ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_pool(id, timeout: nil)
        request("GET", "/pools/#{segment(id, "id")}", timeout: timeout)
      end

      # Add a number to the pool. `POST /pools/{id}/numbers`
      #
      # @param id [String] Pool ID (UUID).
      # @param instance_id [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def add_pool_number(id, instance_id:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id
        )
        request("POST",
                "/pools/#{segment(id, "id")}/numbers",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
