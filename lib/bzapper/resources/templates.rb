# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Templates de mensagem aprovados pela Meta (trilho oficial): criar, sincronizar, mídia e fallback — `client.templates`.
    class Templates < Base
      # List the project templates. `GET /templates`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_templates(timeout: nil)
        request("GET", "/templates", timeout: timeout)
      end

      # Create a template and submit it to Meta for review. `POST /templates`
      #
      # You describe header, body, footer and buttons; we build the component format Meta expects —
      # with its examples nested three levels deep and the rules it does not document alongside.
      # Validation happens BEFORE submission, and that is where this endpoint earns its keep: Meta
      # takes up to 24 hours to answer, rejects with a terse reason, and caps how many templates you
      # may submit. A variable at the start or end of the body, numbering that skips, two variables
      # side by side, a missing example — each returns 422 with a message that says what to fix.
      # `advice` comes back with things that did not block the submission but change the outcome —
      # promotional wording in a UTILITY template, for instance, which Meta reclassifies on its own,
      # and reclassification changes what the conversation COSTS. The decision arrives later through
      # the `template.approved` / `template.rejected` webhooks.
      #
      # @param name [String] (corpo) Lowercase letters, numbers and _. This is the name you send by.
      # @param language [String] (corpo) e.g. pt_BR. Both pt-BR and pt_BR are accepted.
      # @param category [String] (corpo) Decides what the conversation COSTS and what Meta accepts in
      #   the content — not an administrative label. UTILITY is cheaper but only covers what the
      #   customer already expects; promotional wording in it gets reclassified, and the price changes
      #   with it.
      # @param header [Hash, nil] (corpo)
      # @param body [Hash] (corpo)
      # @param footer [String, nil] (corpo) Up to 60 characters. Accepts no variables.
      # @param buttons [Array<Hash>, nil] (corpo)
      # @param code_expiry_minutes [Integer, nil] (corpo) AUTHENTICATION only, 1 to 90. In that
      #   category Meta writes the text itself and adds the copy-code button; this is the only thing you
      #   set.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_template(name:, language:, category:, body:, header: UNSET, footer: UNSET,
                          buttons: UNSET, code_expiry_minutes: UNSET, idempotency_key: nil,
                          timeout: nil)
        payload = compact(
          "name" => name,
          "language" => language,
          "category" => category,
          "header" => header,
          "body" => body,
          "footer" => footer,
          "buttons" => buttons,
          "code_expiry_minutes" => code_expiry_minutes
        )
        request("POST",
                "/templates",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Get one template. `GET /templates/{id}`
      #
      # @param id [String] parâmetro de caminho
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_template(id, timeout: nil)
        request("GET", "/templates/#{segment(id, "id")}", timeout: timeout)
      end

      # Delete a template. `DELETE /templates/{id}`
      #
      # Removes it here and at Meta. Meta deletes ALL languages of a name at once — so when another
      # language of the same name is still registered here, we leave Meta alone rather than delete
      # something you did not ask to delete.
      #
      # @param id [String] parâmetro de caminho
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_template(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/templates/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Import templates that exist at Meta and not here. `POST /templates/sync`
      #
      # For the account that already used the Cloud API before bZapper and created templates in
      # WhatsApp Manager, and to repair a webhook that never arrived. Without it those templates would
      # exist for Meta and be invisible here — and sending by name would say they do not exist.
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def sync_templates(idempotency_key: nil, timeout: nil)
        request("POST", "/templates/sync", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Get the project fallback template. `GET /templates/fallback`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_fallback_template(timeout: nil)
        request("GET", "/templates/fallback", timeout: timeout)
      end

      # Set the template sent when the 24-hour window is closed. `PUT /templates/fallback`
      #
      # This is what makes the same `POST /messages/text` work inside and outside the window. When the
      # contact has not written for over 24 hours, free text is refused by Meta; with a fallback
      # configured, the platform sends this approved template instead and reports the detour in the
      # `delivery` field of the response. Only an APPROVED template is accepted: a fallback that
      # cannot be sent would only postpone the failure to the first send outside the window. An empty
      # `template_id` clears it.
      #
      # @param template_id [String, nil] (corpo) Empty clears the fallback.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def set_fallback_template(template_id: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "template_id" => template_id
        )
        request("PUT",
                "/templates/fallback",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Upload the header sample of a template (multipart, JPEG/PNG/MP4/PDF up to 10 MB). `POST
      # /templates/media`
      #
      # Meta reviews media headers from a sample file. Upload it here and pass the returned `url` as
      # `header.media_url` in POST /templates — no need to host the file anywhere. It is only the
      # sample Meta reviews, not the media that goes out on each send. Samples never used by a
      # template are cleaned up.
      #
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def upload_template_media(file:, filename: nil, content_type: nil, idempotency_key: nil,
                                timeout: nil)
        request("POST",
                "/templates/media",
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
