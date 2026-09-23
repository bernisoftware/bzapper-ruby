# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Contatos (CRM), tags, grupos de contatos, opt-in/out, supressões e checagem — `client.contacts`.
    class Contacts < Base
      # Contact base (list + filters). `GET /contacts`
      #
      # Lists the tenant's contacts — CRM fields plus name (WhatsApp push name), phone, avatar (best
      # effort) and activity. Supports rich filtering (search, tags/groups, location, document,
      # activity/creation windows) and offset pagination.
      #
      # @param search [String, nil] (query) Filter by name, phone, email or document.
      # @param tags [Array<String>, nil] (query) Tag keys (repeat the param or a CSV list).
      # @param tags_match [String, nil] (query) Match ANY (default) or ALL of `tags`.
      # @param groups [Array<String>, nil] (query) Contact-group keys (repeat the param or a CSV
      #   list).
      # @param project_id [String, nil] (query) Scope by project (alternative to the X-Project-Id
      #   header).
      # @param instance_id [String, nil] (query) Filter by a number (instance) the contact interacted
      #   with. The contact↔number link is maintained automatically by the API (inbound/outbound
      #   correlation).
      # @param status [String, nil] (query)
      # @param city [String, nil] (query)
      # @param state [String, nil] (query)
      # @param country [String, nil] (query)
      # @param zip [String, nil] (query)
      # @param document [String, nil] (query)
      # @param has_email [Boolean, nil] (query) Only contacts that have (true) or lack (false) an
      #   email.
      # @param last_activity_after [Time, String, nil] (query) last_message_at ≥ this instant
      #   (RFC3339).
      # @param last_activity_before [Time, String, nil] (query) last_message_at ≤ this instant
      #   (RFC3339).
      # @param created_after [Time, String, nil] (query) created_at ≥ this instant (RFC3339).
      # @param created_before [Time, String, nil] (query) created_at ≤ this instant (RFC3339).
      # @param sort [String, nil] (query)
      # @param limit [Integer, nil] (query)
      # @param offset [Integer, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_contacts(search: nil, tags: nil, tags_match: nil, groups: nil, project_id: nil,
                        instance_id: nil, status: nil, city: nil, state: nil, country: nil,
                        zip: nil, document: nil, has_email: nil, last_activity_after: nil,
                        last_activity_before: nil, created_after: nil, created_before: nil,
                        sort: nil, limit: nil, offset: nil, timeout: nil)
        query = {
          "search" => search,
          "tags" => tags,
          "tags_match" => tags_match,
          "groups" => groups,
          "project_id" => project_id,
          "instance_id" => instance_id,
          "status" => status,
          "city" => city,
          "state" => state,
          "country" => country,
          "zip" => zip,
          "document" => document,
          "has_email" => has_email,
          "last_activity_after" => last_activity_after,
          "last_activity_before" => last_activity_before,
          "created_after" => created_after,
          "created_before" => created_before,
          "sort" => sort,
          "limit" => limit,
          "offset" => offset
        }
        request("GET", "/contacts", query: query, timeout: timeout)
      end

      # Create a contact. `POST /contacts`
      #
      # Creates a contact in the base with CRM fields. `phone` is required (+DDIdigits).
      # Name/email/document/address are optional. Idempotent by phone: if the contact already exists,
      # only its empty fields are filled (never overwritten) and it is returned with 201.
      #
      # @param phone [String] (corpo) +DDIdigits (E.164 without spaces).
      # @param name [String, nil] (corpo)
      # @param email [String, nil] (corpo)
      # @param document [String, nil] (corpo)
      # @param document_type [String, nil] (corpo)
      # @param address [Hash, nil] (corpo) Postal address of the contact.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_contact(phone:, name: UNSET, email: UNSET, document: UNSET, document_type: UNSET,
                         address: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "phone" => phone,
          "name" => name,
          "email" => email,
          "document" => document,
          "document_type" => document_type,
          "address" => address
        )
        request("POST",
                "/contacts",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Import contacts in bulk. `POST /contacts/import`
      #
      # Upserts up to 1000 contacts by phone in one call. A new contact is created with `source:
      # import` and `status: pending_validation` (it needs opt-in before a campaign). An existing one
      # has only its informed fields updated — a blank value never erases what is there. A
      # suppressed/opted-out/blocked contact is reported in `skipped_rows` and never resurrected. Tags
      # and groups are created on demand. A bad row is reported in `errors` and does NOT fail the rest
      # of the call. `dry_run` validates everything and writes nothing.
      #
      # @param contacts [Array<Hash>] (corpo)
      # @param dry_run [Boolean, nil] (corpo) Validates and reports without writing anything.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def import_contacts(contacts:, dry_run: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "contacts" => contacts,
          "dry_run" => dry_run
        )
        request("POST",
                "/contacts/import",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Get a contact. `GET /contacts/{id}`
      #
      # @param id [String] Contact ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_contact(id, timeout: nil)
        request("GET", "/contacts/#{segment(id, "id")}", timeout: timeout)
      end

      # Update a contact. `PATCH /contacts/{id}`
      #
      # Partial update of the contact's CRM fields.
      #
      # @param id [String] Contact ID (UUID).
      # @param name [String, nil] (corpo)
      # @param email [String, nil] (corpo)
      # @param document [String, nil] (corpo)
      # @param document_type [String, nil] (corpo)
      # @param address [Hash, nil] (corpo) Postal address of the contact.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_contact(id, name: UNSET, email: UNSET, document: UNSET, document_type: UNSET,
                         address: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "email" => email,
          "document" => document,
          "document_type" => document_type,
          "address" => address
        )
        request("PATCH",
                "/contacts/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Delete a contact. `DELETE /contacts/{id}`
      #
      # @param id [String] Contact ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_contact(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/contacts/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Contact timeline (messages + events). `GET /contacts/{id}/history`
      #
      # Unified chronological history of the contact — messages (inbound/outbound) and events
      # (opt-out, notes, tag/group changes, status transitions).
      #
      # @param id [String] Contact ID (UUID).
      # @param limit [Integer, nil] (query) Max items.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_contact_history(id, limit: nil, timeout: nil)
        query = {
          "limit" => limit
        }
        request("GET", "/contacts/#{segment(id, "id")}/history", query: query, timeout: timeout)
      end

      # Add an internal note to the contact. `POST /contacts/{id}/notes`
      #
      # The note is internal (audit/CRM), never sent to the contact. Appears in the timeline.
      #
      # @param id [String] Contact ID (UUID).
      # @param body [String] (corpo) Note text (internal, not sent to the contact).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def add_contact_note(id, body:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "body" => body
        )
        request("POST",
                "/contacts/#{segment(id, "id")}/notes",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Add/remove tags on the contact. `POST /contacts/{id}/tags`
      #
      # Batch correlation. Unknown tag keys in `add` are created in the tag dictionary.
      #
      # @param id [String] Contact ID (UUID).
      # @param add [Array<String>, nil] (corpo) Keys to add.
      # @param remove [Array<String>, nil] (corpo) Keys to remove.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def mutate_contact_tags(id, add: UNSET, remove: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "add" => add,
          "remove" => remove
        )
        request("POST",
                "/contacts/#{segment(id, "id")}/tags",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Add/remove contact groups on the contact. `POST /contacts/{id}/groups`
      #
      # Batch correlation with contact groups (NOT WhatsApp groups). Unknown group keys in `add` are
      # created.
      #
      # @param id [String] Contact ID (UUID).
      # @param add [Array<String>, nil] (corpo) Keys to add.
      # @param remove [Array<String>, nil] (corpo) Keys to remove.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def mutate_contact_groups(id, add: UNSET, remove: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "add" => add,
          "remove" => remove
        )
        request("POST",
                "/contacts/#{segment(id, "id")}/groups",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Opt the contact out (LGPD). `POST /contacts/{id}/optout`
      #
      # Marks the contact as opted out (status `opted_out`, sets `opted_out_at`) and adds it to the
      # suppression list. Sends to this contact are blocked afterwards.
      #
      # @param id [String] Contact ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def opt_out_contact(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/contacts/#{segment(id, "id")}/optout",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Manually suppress the contact. `POST /contacts/{id}/suppress`
      #
      # Manual block — sets status `blocked` and adds a suppression entry so the contact stops
      # receiving sends. Distinct from `/contacts/{jid}/block`, which blocks a number at the WhatsApp
      # level.
      #
      # @param id [String] Contact ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def suppress_contact(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/contacts/#{segment(id, "id")}/suppress",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Opt the contact back in (remove suppression). `POST /contacts/{id}/optin`
      #
      # Removes the suppression (opt-out/manual) and reactivates the contact (status `active`).
      #
      # @param id [String] Contact ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def opt_in_contact(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/contacts/#{segment(id, "id")}/optin",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the tag dictionary. `GET /tags`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_tags(timeout: nil)
        request("GET", "/tags", timeout: timeout)
      end

      # Create a tag. `POST /tags`
      #
      # @param key [String] (corpo) Stable slug (unique in the dictionary). Posting an existing key
      #   updates it.
      # @param name [String, nil] (corpo)
      # @param color [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_tag(key:, name: UNSET, color: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "key" => key,
          "name" => name,
          "color" => color
        )
        request("POST", "/tags", body: payload, idempotency_key: idempotency_key, timeout: timeout)
      end

      # Delete a tag. `DELETE /tags/{id}`
      #
      # Removes the tag from the dictionary and unlinks it from every contact.
      #
      # @param id [String] Tag ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_tag(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/tags/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the contact-group dictionary. `GET /contact-groups`
      #
      # Contact groups (CRM segments) — NOT WhatsApp groups (see `/groups`). Bulk correlation happens
      # via the `groups`/`tags` fields on message sends.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_contact_groups(timeout: nil)
        request("GET", "/contact-groups", timeout: timeout)
      end

      # Create a contact group. `POST /contact-groups`
      #
      # @param key [String] (corpo) Stable slug (unique in the dictionary). Posting an existing key
      #   updates it.
      # @param name [String, nil] (corpo)
      # @param color [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_contact_group(key:, name: UNSET, color: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "key" => key,
          "name" => name,
          "color" => color
        )
        request("POST",
                "/contact-groups",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Delete a contact group. `DELETE /contact-groups/{id}`
      #
      # Removes the contact group from the dictionary and unlinks it from every contact.
      #
      # @param id [String] Contact group ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_contact_group(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/contact-groups/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the suppression list. `GET /suppressions`
      #
      # Contacts that must not receive sends (opt-out, manual, bounce, etc.).
      #
      # @param limit [Integer, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_suppressions(limit: nil, timeout: nil)
        query = {
          "limit" => limit
        }
        request("GET", "/suppressions", query: query, timeout: timeout)
      end

      # Add a number to the suppression list. `POST /suppressions`
      #
      # @param phone [String] (corpo) +DDIdigits (E.164 without spaces).
      # @param reason [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_suppression(phone:, reason: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "phone" => phone,
          "reason" => reason
        )
        request("POST",
                "/suppressions",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Remove a number from the suppression list. `DELETE /suppressions`
      #
      # Un-suppresses the number identified by the `phone` query param.
      #
      # @param phone [String] (query) +DDIdigits (E.164 without spaces).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def delete_suppression(phone:, idempotency_key: nil, timeout: nil)
        query = {
          "phone" => phone
        }
        request("DELETE",
                "/suppressions",
                query: query,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Check whether numbers are on WhatsApp (IsOnWhatsApp). `POST /contacts/check`
      #
      # @param instance_id [String] (corpo)
      # @param phones [Array<String>] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def contacts_check(instance_id:, phones:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "instance_id" => instance_id,
          "phones" => phones
        )
        request("POST",
                "/contacts/check",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
