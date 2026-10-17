# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # bZapper Connect do lado do CLIENTE: apps parceiros conectados à conta — `client.connect`.
    class Connect < Base
      # Connected apps — partner software using this account's WhatsApp. `GET /me/connections`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_connected_apps(timeout: nil)
        request("GET", "/me/connections", timeout: timeout)
      end

      # Disconnect a partner app (admin). The partner's key stops working immediately. `DELETE
      # /me/connections/{id}`
      #
      # @param id [String] Connected partner app (connection) ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def revoke_connected_app(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/me/connections/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Convert a partner-created account to general use (admin). The connection stays: the partner
      # keeps working and any partnership discount keeps applying. What changes is that the account
      # may issue its own API keys. Irreversible. `POST /me/connections/{id}/standalone`
      #
      # @param id [String] Connected partner app (connection) ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def convert_connected_app_to_standalone(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/me/connections/#{segment(id, "id")}/standalone",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
