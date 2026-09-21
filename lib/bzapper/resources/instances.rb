# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Números (instâncias): conexão, QR, sessão, proxy, filtros de entrada e conta oficial — `client.instances`.
    class Instances < Base
      # Set the inbound filters (broadcast/status/groups). `PATCH /instances/{id}/inbound-filters`
      #
      # @param id [String] Instance ID (UUID).
      # @param ignore_broadcast [Boolean, nil] (corpo)
      # @param ignore_status [Boolean, nil] (corpo)
      # @param ignore_groups [Boolean, nil] (corpo)
      # @param group_allowlist [Array<String>, nil] (corpo)
      # @param group_denylist [Array<String>, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def set_inbound_filters(id, ignore_broadcast: UNSET, ignore_status: UNSET,
                              ignore_groups: UNSET, group_allowlist: UNSET, group_denylist: UNSET,
                              idempotency_key: nil, timeout: nil)
        payload = compact(
          "ignore_broadcast" => ignore_broadcast,
          "ignore_status" => ignore_status,
          "ignore_groups" => ignore_groups,
          "group_allowlist" => group_allowlist,
          "group_denylist" => group_denylist
        )
        request("PATCH",
                "/instances/#{segment(id, "id")}/inbound-filters",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the tenant's instances (numbers). `GET /instances`
      #
      # @param project_id [String, nil] (query) Scope the numbers by project: a project id, or `all`
      #   for every number in the account. Omit to use the active project (X-Project-Id).
      # @param archived [String, nil] (query) `1` lists the ARCHIVED numbers of the active project
      #   instead of the active ones.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_instances(project_id: nil, archived: nil, timeout: nil)
        query = {
          "project_id" => project_id,
          "archived" => archived
        }
        request("GET", "/instances", query: query, timeout: timeout)
      end

      # Create an instance (number). `POST /instances`
      #
      # @param phone [String] (corpo)
      # @param nickname [String, nil] (corpo)
      # @param proxy_url [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_instance(phone:, nickname: UNSET, proxy_url: UNSET, idempotency_key: nil,
                          timeout: nil)
        payload = compact(
          "phone" => phone,
          "nickname" => nickname,
          "proxy_url" => proxy_url
        )
        request("POST",
                "/instances",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Get an instance. `GET /instances/{id}`
      #
      # @param id [String] Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_instance(id, timeout: nil)
        request("GET", "/instances/#{segment(id, "id")}", timeout: timeout)
      end

      # Remove an instance (ends the session). `DELETE /instances/{id}`
      #
      # Refused for numbers with message history (409 has_history) — archive them instead.
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_instance(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/instances/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Connect the instance via QR or pairing code. `POST /instances/{id}/connect`
      #
      # @param id [String] Instance ID (UUID).
      # @param method [String, nil] (query) `qr` (default) returns a QR; `code` returns an 8-character
      #   code.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def connect_instance(id, method: nil, idempotency_key: nil, timeout: nil)
        query = {
          "method" => method
        }
        request("POST",
                "/instances/#{segment(id, "id")}/connect",
                query: query,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Disconnect (reconnectable). `POST /instances/{id}/disconnect`
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def disconnect_instance(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/instances/#{segment(id, "id")}/disconnect",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Logout (requires a new QR afterwards). `POST /instances/{id}/logout`
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def logout_instance(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/instances/#{segment(id, "id")}/logout",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Wipe the paired device and force a clean re-pairing. `POST /instances/{id}/clear-session`
      #
      # Deletes the stored WhatsApp device credential for this number, not just its reference. Use it
      # when `connect` will not produce a QR code, or when pairing is stuck in an inconsistent state —
      # a plain `logout` leaves the old device behind. The next `connect` pairs from scratch.
      # Destructive and irreversible: the number goes offline and must be paired again by scanning a
      # QR code. It is idempotent and safe to retry.
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def clear_instance_session(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/instances/#{segment(id, "id")}/clear-session",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Archive (deactivate) a number, keeping its history. `POST /instances/{id}/archive`
      #
      # Ends the live session (best effort) and takes the number out of the active list, rotation and
      # reconnect. History is preserved; reactivate with `/unarchive`. Use this instead of DELETE for
      # numbers with message history.
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def archive_instance(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/instances/#{segment(id, "id")}/archive",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Reactivate an archived number (comes back disconnected). `POST /instances/{id}/unarchive`
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def unarchive_instance(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/instances/#{segment(id, "id")}/unarchive",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # The WhatsApp Business (Cloud API) account connected to the project. `GET /official/account`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_official_account(timeout: nil)
        request("GET", "/official/account", timeout: timeout)
      end

      # Connect a WhatsApp Business account to the project (manual credentials). `POST
      # /official/account`
      #
      # Manual connection with credentials (support fallback for the Embedded Signup). The access
      # token is stored encrypted and never returned.
      #
      # @param waba_id [String] (corpo)
      # @param phone_number_id [String] (corpo)
      # @param access_token [String] (corpo)
      # @param display_number [String, nil] (corpo)
      # @param verified_name [String, nil] (corpo)
      # @param status [String, nil] (corpo) Initial status. Omit for PENDENTE.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def connect_official_account(waba_id:, phone_number_id:, access_token:,
                                   display_number: UNSET, verified_name: UNSET, status: UNSET,
                                   idempotency_key: nil, timeout: nil)
        payload = compact(
          "waba_id" => waba_id,
          "phone_number_id" => phone_number_id,
          "access_token" => access_token,
          "display_number" => display_number,
          "verified_name" => verified_name,
          "status" => status
        )
        request("POST",
                "/official/account",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Disconnect the project's WhatsApp Business account. `DELETE /official/account`
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def disconnect_official_account(idempotency_key: nil, timeout: nil)
        request("DELETE", "/official/account", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Set the instance proxy (network / IP isolation). `PATCH /instances/{id}/proxy`
      #
      # @param id [String] Instance ID (UUID).
      # @param proxy_url [String] (corpo) Proxy URL (empty removes it).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def set_instance_proxy(id, proxy_url:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "proxy_url" => proxy_url
        )
        request("PATCH",
                "/instances/#{segment(id, "id")}/proxy",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
