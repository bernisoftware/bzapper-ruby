# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Grupos do WhatsApp: info, participantes, convite, prévia e pedidos de entrada — `client.groups`.
    class Groups < Base
      # List the number's groups. `GET /groups`
      #
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_groups(instance_id:, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET", "/groups", query: query, timeout: timeout)
      end

      # Create a group. `POST /groups`
      #
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param name [String] (corpo)
      # @param participants [Array<String>, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_group(instance_id:, name:, participants: UNSET, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        payload = compact(
          "name" => name,
          "participants" => participants
        )
        request("POST",
                "/groups",
                query: query,
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Join a group via invite link. `POST /groups/join`
      #
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param code [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def join_group(instance_id:, code:, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        payload = compact(
          "code" => code
        )
        request("POST",
                "/groups/join",
                query: query,
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Preview a group from an invite link without joining. `POST /groups/join/preview`
      #
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param code [String] (corpo) Invite code or full https://chat.whatsapp.com/… link.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def preview_group_invite(instance_id:, code:, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        payload = compact(
          "code" => code
        )
        request("POST",
                "/groups/join/preview",
                query: query,
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Group info. `GET /groups/{jid}`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_group(jid, instance_id:, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET", "/groups/#{segment(jid, "jid")}", query: query, timeout: timeout)
      end

      # Update the group name/topic/settings. `PATCH /groups/{jid}`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param name [String, nil] (corpo)
      # @param topic [String, nil] (corpo)
      # @param announce [Boolean, nil] (corpo)
      # @param locked [Boolean, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_group(jid, instance_id:, name: UNSET, topic: UNSET, announce: UNSET,
                       locked: UNSET, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        payload = compact(
          "name" => name,
          "topic" => topic,
          "announce" => announce,
          "locked" => locked
        )
        request("PATCH",
                "/groups/#{segment(jid, "jid")}",
                query: query,
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Add/remove/promote/demote participants. `POST /groups/{jid}/participants`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param action [String] (corpo)
      # @param participants [Array<String>] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_group_participants(jid, instance_id:, action:, participants:,
                                    idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        payload = compact(
          "action" => action,
          "participants" => participants
        )
        request("POST",
                "/groups/#{segment(jid, "jid")}/participants",
                query: query,
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Invite link (optional reset). `GET /groups/{jid}/invite`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param reset [Boolean, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def group_invite_link(jid, instance_id:, reset: nil, timeout: nil)
        query = {
          "instance_id" => instance_id,
          "reset" => reset
        }
        request("GET", "/groups/#{segment(jid, "jid")}/invite", query: query, timeout: timeout)
      end

      # Leave the group. `POST /groups/{jid}/leave`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def leave_group(jid, instance_id:, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("POST",
                "/groups/#{segment(jid, "jid")}/leave",
                query: query,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List pending join requests. `GET /groups/{jid}/join-requests`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def list_join_requests(jid, instance_id:, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET",
                "/groups/#{segment(jid, "jid")}/join-requests",
                query: query,
                timeout: timeout)
      end

      # Approve/reject join requests. `POST /groups/{jid}/join-requests`
      #
      # @param jid [String] Group JID (…@g.us).
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param participants [Array<String>] (corpo)
      # @param approve [Boolean] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_join_requests(jid, instance_id:, participants:, approve:, idempotency_key: nil,
                               timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        payload = compact(
          "participants" => participants,
          "approve" => approve
        )
        request("POST",
                "/groups/#{segment(jid, "jid")}/join-requests",
                query: query,
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
