# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Cobrança: plano, assinatura, add-ons, faturas e preços — `client.billing`.
    class Billing < Base
      # Effective account limits (plan + add-ons + usage). `GET /me/entitlements`
      #
      # Returns the resolved entitlement of the authenticated account: its effective plan, limits,
      # contracted add-ons, free allowances per pillar and period usage. This is what the UI uses for
      # the usage meter.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_my_entitlements(timeout: nil)
        request("GET", "/me/entitlements", timeout: timeout)
      end

      # Put the Pro plan in the cart (pending until the cart is paid). `POST /me/plan/upgrade`
      #
      # Does not charge nor activate anything: Pro goes into the cart together with any add-ons, and
      # is activated when the cart is paid (`POST /me/addons/cart/checkout`).
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def upgrade_plan(idempotency_key: nil, timeout: nil)
        request("POST", "/me/plan/upgrade", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Cancel Pro at the end of the current cycle. `POST /me/plan/cancel`
      #
      # Pro stays active until renewal, then the account drops to Free.
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def cancel_plan(idempotency_key: nil, timeout: nil)
        request("POST", "/me/plan/cancel", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Undo a scheduled Pro cancellation. `POST /me/plan/uncancel`
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def uncancel_plan(idempotency_key: nil, timeout: nil)
        request("POST", "/me/plan/uncancel", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Plan/subscription state (null on Free). `GET /me/subscription`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_my_subscription(timeout: nil)
        request("GET", "/me/subscription", timeout: timeout)
      end

      # Add (+) or remove (−) add-ons in the cart. `POST /me/addons`
      #
      # A positive `delta` adds to the cart (charged only when the cart is paid); a negative one
      # reduces the cart or the active quantity. Requires Pro (409 not_pro).
      #
      # @param kind [String] (corpo) Quantity add-ons: number, project, storage_gb, retention_block
      #   (+30 days). Feature toggles (0/1): campaigns, schedule_year.
      # @param delta [Integer] (corpo) Non-zero. > 0 adds to the cart; < 0 reduces the cart/active
      #   quantity.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def change_addon(kind:, delta:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "kind" => kind,
          "delta" => delta
        )
        request("POST",
                "/me/addons",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Cart state (pending Pro/add-ons + prorated total). `GET /me/addons/cart`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_addon_cart(timeout: nil)
        request("GET", "/me/addons/cart", timeout: timeout)
      end

      # Empty the cart. `DELETE /me/addons/cart`
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def clear_addon_cart(idempotency_key: nil, timeout: nil)
        request("DELETE", "/me/addons/cart", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Pay the cart (creates the invoice and opens the in-app payment). `POST
      # /me/addons/cart/checkout`
      #
      # Returns the Stripe `client_secret` for Stripe Elements plus the invoice id. With `save_card:
      # true`, the card is kept for recurring charges once the invoice is paid.
      #
      # @param save_card [Boolean, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def checkout_addon_cart(save_card: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "save_card" => save_card
        )
        request("POST",
                "/me/addons/cart/checkout",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # The account's invoices (latest 24, newest first). `GET /me/invoices`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_my_invoices(timeout: nil)
        request("GET", "/me/invoices", timeout: timeout)
      end

      # Reopen the in-app payment of an open invoice. `POST /me/invoices/{id}/pay`
      #
      # @param id [String] Invoice ID.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def pay_invoice(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/me/invoices/#{segment(id, "id")}/pay",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Stripe publishable key for the front-end checkout. `GET /billing/config`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_billing_config(timeout: nil)
        request("GET", "/billing/config", timeout: timeout)
      end

      # Public rate card per currency (plans, add-ons, free allowances). `GET /pricing`
      #
      # Public (no authentication). Cached for 5 minutes.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_pricing(timeout: nil)
        request("GET", "/pricing", timeout: timeout)
      end
    end
  end
end
