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
      # @param limited_time_offer [Hash, nil] (corpo) MARKETING only. Turns the template into a
      #   limited-time offer: a badge (up to 16 characters) and, with `has_expiration`, a countdown to
      #   the deadline sent in `offer_expires_at`. No footer; header only image or video; needs a URL
      #   button (and, with a deadline, the copy-code button).
      # @param cards [Array<Hash>, nil] (corpo) Carousel (MARKETING or UTILITY): 2 to 10 cards. The
      #   template keeps only the opening `body`; each card has its own image or video, text (up to 160
      #   characters) and 1–2 buttons (quick reply, URL or phone). Meta requires the same media type and
      #   the same button types, in the same order, on every card.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_template(name:, language:, category:, body:, header: UNSET, footer: UNSET,
                          buttons: UNSET, code_expiry_minutes: UNSET, limited_time_offer: UNSET,
                          cards: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "language" => language,
          "category" => category,
          "header" => header,
          "body" => body,
          "footer" => footer,
          "buttons" => buttons,
          "code_expiry_minutes" => code_expiry_minutes,
          "limited_time_offer" => limited_time_offer,
          "cards" => cards
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

      # Edit a template (content goes back to Meta review). `PUT /templates/{id}`
      #
      # Same body as creation; `name` and `language` are the template identity and do not change. Meta
      # allows editing an APPROVED template once every 24 hours and ten times in 30 days (rejected or
      # paused: no limit), sends it back to review (the template returns to `PENDING` and does not
      # send until the decision arrives by webhook) and does not let an approved template change
      # category.
      #
      # @param id [String] parâmetro de caminho
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
      # @param limited_time_offer [Hash, nil] (corpo) MARKETING only. Turns the template into a
      #   limited-time offer: a badge (up to 16 characters) and, with `has_expiration`, a countdown to
      #   the deadline sent in `offer_expires_at`. No footer; header only image or video; needs a URL
      #   button (and, with a deadline, the copy-code button).
      # @param cards [Array<Hash>, nil] (corpo) Carousel (MARKETING or UTILITY): 2 to 10 cards. The
      #   template keeps only the opening `body`; each card has its own image or video, text (up to 160
      #   characters) and 1–2 buttons (quick reply, URL or phone). Meta requires the same media type and
      #   the same button types, in the same order, on every card.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def edit_template(id, name:, language:, category:, body:, header: UNSET, footer: UNSET,
                        buttons: UNSET, code_expiry_minutes: UNSET, limited_time_offer: UNSET,
                        cards: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "language" => language,
          "category" => category,
          "header" => header,
          "body" => body,
          "footer" => footer,
          "buttons" => buttons,
          "code_expiry_minutes" => code_expiry_minutes,
          "limited_time_offer" => limited_time_offer,
          "cards" => cards
        )
        request("PUT",
                "/templates/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
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

      # Browse Meta's Template Library (ready-made utility and authentication texts). `GET
      # /templates/library`
      #
      # Texts Meta has already approved. A template created from one of them without changing the text
      # is approved immediately — no 24-hour review.
      #
      # @param search [String, nil] (query) Free text: order, delivery, payment…
      # @param topic [String, nil] (query)
      # @param usecase [String, nil] (query)
      # @param industry [String, nil] (query)
      # @param language [String, nil] (query) e.g. pt_BR.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_library_templates(search: nil, topic: nil, usecase: nil, industry: nil,
                                 language: nil, timeout: nil)
        query = {
          "search" => search,
          "topic" => topic,
          "usecase" => usecase,
          "industry" => industry,
          "language" => language
        }
        request("GET", "/templates/library", query: query, timeout: timeout)
      end

      # Create a template from the Template Library. `POST /templates/library`
      #
      # The text is Meta's, unchanged — that is what makes it approved at once. You only provide what
      # the buttons need: the site link of a URL button (with an example of the variable suffix, when
      # there is one) or the phone of a call button. Authentication items take `code_expiry_minutes`.
      #
      # @param library_template_name [String] (corpo)
      # @param name [String, nil] (corpo) Your template name (defaults to the library name).
      # @param language [String] (corpo)
      # @param button_inputs [Array<Hash>, nil] (corpo) What each URL / phone button of the library
      #   template needs, in order.
      # @param code_expiry_minutes [Integer, nil] (corpo) Authentication items only (default 10).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_template_from_library(library_template_name:, language:, name: UNSET,
                                       button_inputs: UNSET, code_expiry_minutes: UNSET,
                                       idempotency_key: nil, timeout: nil)
        payload = compact(
          "library_template_name" => library_template_name,
          "name" => name,
          "language" => language,
          "button_inputs" => button_inputs,
          "code_expiry_minutes" => code_expiry_minutes
        )
        request("POST",
                "/templates/library",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Performance of each template (sent, delivered, read, failed). `GET /templates/analytics`
      #
      # Counted from the messages sent through each template in the last `days` days, grouped by
      # template name.
      #
      # @param days [Integer, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_template_analytics(days: nil, timeout: nil)
        query = {
          "days" => days
        }
        request("GET", "/templates/analytics", query: query, timeout: timeout)
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

      # Get the verification-code template and whether Meta allows Authentication templates. `GET
      # /templates/otp`
      #
      # The template that carries the code of POST /messages/otp when the 24-hour window is closed
      # (null = the first approved Authentication template is used), plus the account's eligibility
      # for the Authentication category: Meta requires the business to be verified and the number to
      # reach the 2,000-a-day sending limit. Each criterion comes with its current state, so the
      # customer knows what is missing.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_otp_template(timeout: nil)
        request("GET", "/templates/otp", timeout: timeout)
      end

      # Choose the template that carries the verification code outside the window. `PUT
      # /templates/otp`
      #
      # Must be an APPROVED template of the Authentication category or — until Meta releases that
      # category for the account (business verification + 2,000 daily limit) — a provisional Utility
      # template with a copy-code button and at most one body variable; the code goes in the variable
      # and in the button. An empty `template_id` clears the choice (the first approved Authentication
      # template is used again).
      #
      # @param template_id [String, nil] (corpo) Empty clears the choice.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def set_otp_template(template_id: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "template_id" => template_id
        )
        request("PUT",
                "/templates/otp",
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
