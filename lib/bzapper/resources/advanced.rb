# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Recursos avançados: editar/apagar/encaminhar, perfil, privacidade, chats, etiquetas, bloqueio e chamadas — `client.advanced`.
    class Advanced < Base
      # Edit the text of a sent message. `PATCH /messages/{id}`
      #
      # @param id [String] bZapper message ID (UUID) — the `id` returned when the message was queued.
      # @param text [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def edit_message(id, text:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "text" => text
        )
        request("PATCH",
                "/messages/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Revoke a message (delete for everyone). `DELETE /messages/{id}`
      #
      # @param id [String] bZapper message ID (UUID) — the `id` returned when the message was queued.
      # @param for_everyone [Boolean, nil] (query)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def revoke_message(id, for_everyone: nil, idempotency_key: nil, timeout: nil)
        query = {
          "for_everyone" => for_everyone
        }
        request("DELETE",
                "/messages/#{segment(id, "id")}",
                query: query,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Forward a message (experimental). `POST /messages/forward`
      #
      # @param instance_id [String] (corpo)
      # @param to [String] (corpo)
      # @param from_chat [String] (corpo)
      # @param wa_message_id [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def forward_message(instance_id:, to:, from_chat:, wa_message_id:, idempotency_key: nil,
                          timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "to" => to,
          "from_chat" => from_chat,
          "wa_message_id" => wa_message_id
        )
        request("POST",
                "/messages/forward",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Number profile (white-label) — status (ok), name/photo (experimental). `PATCH
      # /instances/{id}/profile`
      #
      # @param id [String] Instance ID (UUID).
      # @param display_name [String, nil] (corpo)
      # @param status_message [String, nil] (corpo)
      # @param picture [String, nil] (corpo) Photo in base64.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def set_profile(id, display_name: UNSET, status_message: UNSET, picture: UNSET,
                      idempotency_key: nil, timeout: nil)
        payload = compact(
          "display_name" => display_name,
          "status_message" => status_message,
          "picture" => picture
        )
        request("PATCH",
                "/instances/#{segment(id, "id")}/profile",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Set a privacy setting. `PATCH /instances/{id}/privacy`
      #
      # @param id [String] Instance ID (UUID).
      # @param setting [String] (corpo)
      # @param value [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def set_privacy(id, setting:, value:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "setting" => setting,
          "value" => value
        )
        request("PATCH",
                "/instances/#{segment(id, "id")}/privacy",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Archive/unarchive a chat. `POST /chats/{jid}/archive`
      #
      # @param jid [String] Chat JID — contact (…@s.whatsapp.net / …@lid) or group (…@g.us).
      # @param instance_id [String] (corpo)
      # @param on [Boolean] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def archive_chat(jid, instance_id:, on:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "on" => on
        )
        request("POST",
                "/chats/#{segment(jid, "jid")}/archive",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Pin/unpin a chat. `POST /chats/{jid}/pin`
      #
      # @param jid [String] Chat JID — contact (…@s.whatsapp.net / …@lid) or group (…@g.us).
      # @param instance_id [String] (corpo)
      # @param on [Boolean] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def pin_chat(jid, instance_id:, on:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "on" => on
        )
        request("POST",
                "/chats/#{segment(jid, "jid")}/pin",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Mark a chat read/unread. `POST /chats/{jid}/read`
      #
      # @param jid [String] Chat JID — contact (…@s.whatsapp.net / …@lid) or group (…@g.us).
      # @param instance_id [String] (corpo)
      # @param on [Boolean] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def mark_chat(jid, instance_id:, on:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "on" => on
        )
        request("POST",
                "/chats/#{segment(jid, "jid")}/read",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Mute/unmute a chat. `POST /chats/{jid}/mute`
      #
      # @param jid [String] Chat JID — contact (…@s.whatsapp.net / …@lid) or group (…@g.us).
      # @param instance_id [String] (corpo)
      # @param on [Boolean] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def mute_chat(jid, instance_id:, on:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "on" => on
        )
        request("POST",
                "/chats/#{segment(jid, "jid")}/mute",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Apply/remove a label on a chat (experimental). `POST /chats/{jid}/labels`
      #
      # @param jid [String] Chat JID — contact (…@s.whatsapp.net / …@lid) or group (…@g.us).
      # @param instance_id [String] (corpo)
      # @param label_id [String] (corpo)
      # @param apply [Boolean, nil] (corpo) true = apply, false = remove.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def apply_chat_label(jid, instance_id:, label_id:, apply: UNSET, idempotency_key: nil,
                           timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "label_id" => label_id,
          "apply" => apply
        )
        request("POST",
                "/chats/#{segment(jid, "jid")}/labels",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the number's labels (experimental). `GET /labels`
      #
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_labels(instance_id:, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET", "/labels", query: query, timeout: timeout)
      end

      # Create a label (experimental). `POST /labels`
      #
      # @param instance_id [String] (corpo)
      # @param name [String] (corpo)
      # @param color [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_label(instance_id:, name:, color: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "name" => name,
          "color" => color
        )
        request("POST",
                "/labels",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Delete a label (experimental). `DELETE /labels/{id}`
      #
      # @param id [String] Label ID.
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_label(id, instance_id:, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("DELETE",
                "/labels/#{segment(id, "id")}",
                query: query,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Block a contact. `POST /contacts/{jid}/block`
      #
      # @param jid [String] Contact JID (…@s.whatsapp.net) to block/unblock.
      # @param instance_id [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def block_contact(jid, instance_id:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id
        )
        request("POST",
                "/contacts/#{segment(jid, "jid")}/block",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Unblock a contact. `POST /contacts/{jid}/unblock`
      #
      # @param jid [String] Contact JID (…@s.whatsapp.net) to block/unblock.
      # @param instance_id [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def unblock_contact(jid, instance_id:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id
        )
        request("POST",
                "/contacts/#{segment(jid, "jid")}/unblock",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List blocked contacts. `GET /blocklist`
      #
      # @param instance_id [String] (query) Instance ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_blocklist(instance_id:, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET", "/blocklist", query: query, timeout: timeout)
      end

      # Reject a call. `POST /calls/reject`
      #
      # @param instance_id [String] (corpo)
      # @param call_from [String] (corpo)
      # @param call_id [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def reject_call(instance_id:, call_from:, call_id:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "call_from" => call_from,
          "call_id" => call_id
        )
        request("POST",
                "/calls/reject",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Start a call (experimental). `POST /calls/offer`
      #
      # @param instance_id [String] (corpo)
      # @param to [String] (corpo)
      # @param video [Boolean, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def offer_call(instance_id:, to:, video: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "to" => to,
          "video" => video
        )
        request("POST",
                "/calls/offer",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
