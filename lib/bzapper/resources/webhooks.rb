# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Webhooks de eventos (gestão, teste, entregas) — `client.webhooks`.
    class Webhooks < Base
      # List webhooks. `GET /webhooks`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_webhooks(timeout: nil)
        request("GET", "/webhooks", timeout: timeout)
      end

      # Register a webhook. `POST /webhooks`
      #
      # @param url [String] (corpo)
      # @param secret [String, nil] (corpo) HMAC-SHA256 secret (stored encrypted). Omit to have a
      #   strong `whsec_...` secret generated and returned once.
      # @param event_types [Array<String>, nil] (corpo) Empty = all events.
      # @param number_filter [String, nil] (corpo) instance_id; empty = all.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_webhook(url:, secret: UNSET, event_types: UNSET, number_filter: UNSET,
                         idempotency_key: nil, timeout: nil)
        payload = compact(
          "url" => url,
          "secret" => secret,
          "event_types" => event_types,
          "number_filter" => number_filter
        )
        request("POST",
                "/webhooks",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Update a webhook (send `secret: "regenerate"` to rotate the secret). `PATCH /webhooks/{id}`
      #
      # Replaces url, event types, number filter and active flag. `url` is required. `active` omitted
      # = true. With `secret: "regenerate"` a new secret is generated and returned ONCE in the
      # response; any other non-empty `secret` replaces it.
      #
      # @param id [String] Webhook ID (UUID).
      # @param url [String] (corpo)
      # @param secret [String, nil] (corpo) Empty = keep. "regenerate" = rotate (returned once).
      # @param event_types [Array<String>, nil] (corpo) Empty = all events.
      # @param number_filter [String, nil] (corpo) instance_id; empty = all.
      # @param active [Boolean, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_webhook(id, url:, secret: UNSET, event_types: UNSET, number_filter: UNSET,
                         active: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "url" => url,
          "secret" => secret,
          "event_types" => event_types,
          "number_filter" => number_filter,
          "active" => active
        )
        request("PATCH",
                "/webhooks/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Remove a webhook. `DELETE /webhooks/{id}`
      #
      # @param id [String] Webhook ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_webhook(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/webhooks/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a signed sample event to this webhook and report the result. `POST /webhooks/{id}/test`
      #
      # @param id [String] Webhook ID (UUID).
      # @param event_type [String, nil] (corpo) Event type of the sample (default a generic one).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def test_webhook(id, event_type: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "event_type" => event_type
        )
        request("POST",
                "/webhooks/#{segment(id, "id")}/test",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Latest deliveries of a webhook. `GET /webhooks/{id}/deliveries`
      #
      # @param id [String] Webhook ID (UUID).
      # @param limit [Integer, nil] (query) 1–200 (default 50).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def list_webhook_deliveries(id, limit: nil, timeout: nil)
        query = {
          "limit" => limit
        }
        request("GET", "/webhooks/#{segment(id, "id")}/deliveries", query: query, timeout: timeout)
      end

      # Emit a sample event to the project's stream and webhooks (like `stripe trigger`). `POST
      # /webhooks/trigger`
      #
      # @param event_type [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def trigger_webhook_event(event_type: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "event_type" => event_type
        )
        request("POST",
                "/webhooks/trigger",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
