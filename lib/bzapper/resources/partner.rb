# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Operações do bZapper Connect do lado do PARCEIRO (`/partner/*`) — métodos do
    # {Bzapper::PartnerClient}.
    module PartnerOperations
      # Partner identity (who the partner secret belongs to). `GET /partner/me`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_partner_me(timeout: nil)
        request("GET", "/partner/me", timeout: timeout)
      end

      # Open a Connect session for one of your customers (backend → bZapper). `POST
      # /partner/connect-sessions`
      #
      # Creates (or reuses) the **connection** of your customer (`external_id` = the customer id in
      # YOUR system) and returns a short-lived `session_token` (30 min) that opens the embedded
      # component (`BzapperConnect.open({ session })`). The customer data you send is trusted: you
      # already authenticated this person in your product, so inside the component the account is
      # created **without password, captcha or email confirmation**. Exception: if the email already
      # has a bZapper account, the component asks for a code sent to that email before linking it.
      # Call this from your **backend** only — the partner secret must never reach a browser.
      #
      # @param external_id [String] (corpo) Your id for this customer. Same id = same connection.
      # @param customer [Hash] (corpo) Your customer, as authenticated in your product. `name` or
      #   `company` is required.
      # @param locale [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_connect_session(external_id:, customer:, locale: UNSET, idempotency_key: nil,
                                 timeout: nil)
        payload = compact(
          "external_id" => external_id,
          "customer" => customer,
          "locale" => locale
        )
        request("POST",
                "/partner/connect-sessions",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Exchange the completion code for the customer's API key. `POST /partner/connect/exchange`
      #
      # When the customer finishes (Pro paid + WhatsApp connected), the component emits
      # `bzapper:complete` with a one-time `code` (valid 10 min). Send it to your backend and exchange
      # it here. The response carries the **raw API key** (`bz_live_...`) — store it; it is not shown
      # again (use `rotate-key` if lost).
      #
      # @param code [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def exchange_connect_code(code:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "code" => code
        )
        request("POST",
                "/partner/connect/exchange",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List your connections (filter by external_id / status). `GET /partner/connections`
      #
      # @param external_id [String, nil] (query)
      # @param status [String, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_partner_connections(external_id: nil, status: nil, timeout: nil)
        query = {
          "external_id" => external_id,
          "status" => status
        }
        request("GET", "/partner/connections", query: query, timeout: timeout)
      end

      # Get one connection (status, account, numbers). `GET /partner/connections/{id}`
      #
      # @param id [String] Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_partner_connection(id, timeout: nil)
        request("GET", "/partner/connections/#{segment(id, "id")}", timeout: timeout)
      end

      # End a connection (revokes the key; does NOT cancel the customer's plan). `DELETE
      # /partner/connections/{id}`
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def revoke_partner_connection(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/partner/connections/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Issue a new API key for a completed connection (the previous key stops working). `POST
      # /partner/connections/{id}/rotate-key`
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def rotate_partner_connection_key(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/partner/connections/#{segment(id, "id")}/rotate-key",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
