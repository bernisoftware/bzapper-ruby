# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Envio de mensagens (todos os tipos, OTP), presença e confirmação de leitura — `client.messages`.
    class Messages < Base
      # Send a text message. `POST /messages/text`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param body [String] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_text(to:, body:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                    quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                    mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET, force: UNSET,
                    idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "body" => body
        )
        request("POST",
                "/messages/text",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send an image (url or base64). `POST /messages/image`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param media [Hash] (corpo) Media by URL **or** base64 (never both).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_image(to:, media:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                     quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                     mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET,
                     force: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "media" => media
        )
        request("POST",
                "/messages/image",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a video. `POST /messages/video`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param media [Hash] (corpo) Media by URL **or** base64 (never both).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_video(to:, media:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                     quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                     mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET,
                     force: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "media" => media
        )
        request("POST",
                "/messages/video",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a document. `POST /messages/document`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param media [Hash] (corpo) Media by URL **or** base64 (never both).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_document(to:, media:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                        quoted_message_id: UNSET, quoted_participant: UNSET,
                        client_reference: UNSET, mentions: UNSET, scheduled_at: UNSET,
                        groups: UNSET, tags: UNSET, force: UNSET, idempotency_key: nil,
                        timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "media" => media
        )
        request("POST",
                "/messages/document",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send audio (optional ptt = voice note). `POST /messages/audio`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param media [Hash] (corpo) Media by URL **or** base64 (never both).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_audio(to:, media:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                     quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                     mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET,
                     force: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "media" => media
        )
        request("POST",
                "/messages/audio",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a sticker. `POST /messages/sticker`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param media [Hash] (corpo) Media by URL **or** base64 (never both).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_sticker(to:, media:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                       quoted_message_id: UNSET, quoted_participant: UNSET,
                       client_reference: UNSET, mentions: UNSET, scheduled_at: UNSET,
                       groups: UNSET, tags: UNSET, force: UNSET, idempotency_key: nil,
                       timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "media" => media
        )
        request("POST",
                "/messages/sticker",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a location. `POST /messages/location`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param latitude [Numeric] (corpo)
      # @param longitude [Numeric] (corpo)
      # @param name [String, nil] (corpo)
      # @param address [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_location(to:, latitude:, longitude:, instance_id: UNSET, pool_id: UNSET,
                        sticky: UNSET, quoted_message_id: UNSET, quoted_participant: UNSET,
                        client_reference: UNSET, mentions: UNSET, scheduled_at: UNSET,
                        groups: UNSET, tags: UNSET, force: UNSET, name: UNSET, address: UNSET,
                        idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "latitude" => latitude,
          "longitude" => longitude,
          "name" => name,
          "address" => address
        )
        request("POST",
                "/messages/location",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a contact (vCard). `POST /messages/contact`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param contact_name [String, nil] (corpo)
      # @param contact_vcard [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_contact(to:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                       quoted_message_id: UNSET, quoted_participant: UNSET,
                       client_reference: UNSET, mentions: UNSET, scheduled_at: UNSET,
                       groups: UNSET, tags: UNSET, force: UNSET, contact_name: UNSET,
                       contact_vcard: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "contact_name" => contact_name,
          "contact_vcard" => contact_vcard
        )
        request("POST",
                "/messages/contact",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a poll. `POST /messages/poll`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param name [String] (corpo)
      # @param options [Array<String>] (corpo)
      # @param selectable_count [Integer, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_poll(to:, name:, options:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                    quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                    mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET, force: UNSET,
                    selectable_count: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "name" => name,
          "options" => options,
          "selectable_count" => selectable_count
        )
        request("POST",
                "/messages/poll",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # React to a message. `POST /messages/reaction`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param emoji [String, nil] (corpo) Reaction emoji. Empty string removes a previous reaction.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_reaction(to:, quoted_message_id:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                        quoted_participant: UNSET, client_reference: UNSET, mentions: UNSET,
                        scheduled_at: UNSET, groups: UNSET, tags: UNSET, force: UNSET,
                        emoji: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "emoji" => emoji
        )
        request("POST",
                "/messages/reaction",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send buttons (automatic fallback to a text menu). `POST /messages/buttons`
      #
      # Buttons are not reliable on WhatsApp (worse in groups). The API **always** sends an equivalent
      # **numbered text menu** as a fallback.
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param body [String] (corpo)
      # @param footer [String, nil] (corpo)
      # @param buttons [Array<Hash>] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_buttons(to:, body:, buttons:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                       quoted_message_id: UNSET, quoted_participant: UNSET,
                       client_reference: UNSET, mentions: UNSET, scheduled_at: UNSET,
                       groups: UNSET, tags: UNSET, force: UNSET, footer: UNSET,
                       idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "body" => body,
          "footer" => footer,
          "buttons" => buttons
        )
        request("POST",
                "/messages/buttons",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send a list (automatic fallback to a text menu). `POST /messages/list`
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param body [String] (corpo)
      # @param footer [String, nil] (corpo)
      # @param button_text [String, nil] (corpo)
      # @param sections [Array<Hash>] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_list(to:, body:, sections:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                    quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                    mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET, force: UNSET,
                    footer: UNSET, button_text: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "body" => body,
          "footer" => footer,
          "button_text" => button_text,
          "sections" => sections
        )
        request("POST",
                "/messages/list",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Send an OTP code (text + code in separate messages). `POST /messages/otp`
      #
      # Sends a verification code as TWO messages — the context text and the code alone in a bubble —
      # so the recipient can copy the code on any device (long-press the bubble). Counts as ONE send
      # (type=otp). If `body` is omitted, the API generates the text in the account language with
      # variations (reduces the block risk). The code is never persisted nor shown in the inbox.
      #
      # @param instance_id [String, nil] (corpo) OPTIONAL. Only `to` is required. Omit `instance_id`
      #   to let the gateway auto-pick a number from your pool (rotation + conversation affinity) — the
      #   recommended path. Provide it ONLY to FORCE the send from a specific number. Get ids from `GET
      #   /instances`.
      # @param pool_id [String, nil] (corpo) Rotates within this pool (when instance_id is omitted).
      # @param sticky [Boolean, nil] (corpo) Conversation affinity (support): without
      #   instance_id/pool_id, it AUTOMATICALLY reuses the number that already talks to `to`, ensuring
      #   the whole interaction stays on the same number. Default **true**; send **false** to force
      #   rotation (e.g. campaign/broadcast).
      # @param to [String] (corpo) Destination E.164 phone or JID.
      # @param quoted_message_id [String, nil] (corpo) Quoted wa_message_id (reply).
      # @param quoted_participant [String, nil] (corpo) Author (phone or JID) of the quoted/reacted
      #   message. Only needed in groups when the quoted message is not in bZapper history — otherwise
      #   it is resolved automatically.
      # @param client_reference [String, nil] (corpo) Client end-to-end correlation.
      # @param mentions [Array<String>, nil] (corpo) Mentioned people (group): phones ("5511…", "+55
      #   11 9…") or JIDs. The body must contain "@<digits>" for the mention to be highlighted.
      # @param scheduled_at [Time, String, nil] (corpo) OPTIONAL. Schedule the send for a future
      #   RFC3339 timestamp. The gateway holds the message and dispatches it at that exact time (the
      #   number is picked at send time). Max lead time by plan: Free 24h, Pro 30 days, and up to 1 year
      #   with the "Extended scheduling" add-on. Returns status `scheduled` with a `scheduled_id`. OTP
      #   cannot be scheduled.
      # @param groups [Array<String>, nil] (corpo) OPTIONAL. Contact-group keys to correlate/stamp
      #   onto the recipient contact when this send resolves (see `GET /contact-groups`). Does not send
      #   the message to a WhatsApp group.
      # @param tags [Array<String>, nil] (corpo) OPTIONAL. Tag keys to correlate/stamp onto the
      #   recipient contact when this send resolves (see `GET /tags`).
      # @param force [Boolean, nil] (corpo) OPTIONAL. When true, bypasses an inferred suppression
      #   (e.g. opt-out inferred from behaviour) for this send. Does NOT override an explicit
      #   suppression entry (`/suppressions`) — use with care and only with a lawful basis.
      # @param code [String] (corpo) The verification code. Goes alone in a bubble (copyable).
      # @param body [String, nil] (corpo) Context text (optional). Empty → generated in the account
      #   language, with variations.
      # @param expiry_minutes [Integer, nil] (corpo) Optional — mentions the expiry in the generated
      #   text.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def send_otp(to:, code:, instance_id: UNSET, pool_id: UNSET, sticky: UNSET,
                   quoted_message_id: UNSET, quoted_participant: UNSET, client_reference: UNSET,
                   mentions: UNSET, scheduled_at: UNSET, groups: UNSET, tags: UNSET, force: UNSET,
                   body: UNSET, expiry_minutes: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "pool_id" => pool_id,
          "sticky" => sticky,
          "to" => to,
          "quoted_message_id" => quoted_message_id,
          "quoted_participant" => quoted_participant,
          "client_reference" => client_reference,
          "mentions" => mentions,
          "scheduled_at" => scheduled_at,
          "groups" => groups,
          "tags" => tags,
          "force" => force,
          "code" => code,
          "body" => body,
          "expiry_minutes" => expiry_minutes
        )
        request("POST",
                "/messages/otp",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Mark messages as read. `POST /messages/{id}/read`
      #
      # @param id [String] WhatsApp message id to mark read (used when the body has no `message_ids`).
      # @param instance_id [String] (corpo)
      # @param chat [String] (corpo) Chat JID.
      # @param wa_message_ids [Array<String>, nil] (corpo)
      # @param sender [String, nil] (corpo) Author (phone or JID) of the messages. Groups only; when
      #   omitted, each message's stored author is used (400 `sender_required` if none is known).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def mark_read(id, instance_id:, chat:, wa_message_ids: UNSET, sender: UNSET,
                    idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "chat" => chat,
          "wa_message_ids" => wa_message_ids,
          "sender" => sender
        )
        request("POST",
                "/messages/#{segment(id, "id")}/read",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Update presence in a chat (typing/recording/paused). `POST /presence/chat`
      #
      # @param instance_id [String] (corpo)
      # @param to [String] (corpo)
      # @param state [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def presence_chat(instance_id:, to:, state: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "to" => to,
          "state" => state
        )
        request("POST",
                "/presence/chat",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
