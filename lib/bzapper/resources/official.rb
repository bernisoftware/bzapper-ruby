# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Trilho oficial (WhatsApp Cloud API): conta WABA, Embedded Signup, números e perfil comercial — `client.official`.
    class Official < Base
      # Read the WhatsApp Business Account connected to the project. `GET /official/account`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_official_account(timeout: nil)
        request("GET", "/official/account", timeout: timeout)
      end

      # Connect (or reconnect) a WhatsApp Business Account to the project. `POST /official/account`
      #
      # Stores the customer's Meta credentials for the project. Calling it again replaces them — that
      # is the reconnection path when a token is revoked, and it never creates a second account for
      # the same project. `phone_number_id` is optional: when omitted, the number is discovered from
      # the WABA. If the WABA holds more than one number the call returns 409 with the list, so the
      # choice stays with the account owner instead of being guessed.
      #
      # @param waba_id [String] (corpo)
      # @param phone_number_id [String, nil] (corpo) Optional — discovered from the WABA when omitted.
      # @param access_token [String] (corpo) The customer's WABA token, stored encrypted at rest. A
      #   token taken from Meta's "API Setup" screen expires in 24h; for a lasting connection use a
      #   system user with `whatsapp_business_messaging` + `whatsapp_business_management`.
      # @param display_number [String, nil] (corpo)
      # @param verified_name [String, nil] (corpo)
      # @param status [String, nil] (corpo) Empty means PENDENTE, which is the correct state coming
      #   out of Embedded Signup.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def connect_official_account(waba_id:, access_token:, phone_number_id: UNSET,
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

      # Disconnect the account from the project. `DELETE /official/account`
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def disconnect_official_account(idempotency_key: nil, timeout: nil)
        request("DELETE", "/official/account", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Read what the browser needs to open Meta's Embedded Signup. `GET /official/signup-config`
      #
      # Returns the app and configuration ids the Meta JS SDK needs. Both are public by nature — the
      # customer's browser sees them. The app secret never leaves the server: the one-time `code` the
      # popup returns is exchanged for a token server-side. `enabled` false means this installation
      # has no Embedded Signup configured, and the UI should offer the manual path instead of a button
      # that cannot work.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_official_signup_config(timeout: nil)
        request("GET", "/official/signup-config", timeout: timeout)
      end

      # Finish the connection with the code returned by Meta's popup. `POST /official/embedded-signup`
      #
      # Exchanges the one-time `code` for a lasting token, subscribes the app to the WABA's webhooks
      # and registers the number on the Cloud API. The customer never sees or types a credential. The
      # code expires about 30 seconds after the popup closes, so send it straight through. A non-fatal
      # step that fails comes back in `warning` instead of losing the whole connection: the account is
      # stored either way and the UI offers a retry.
      #
      # @param code [String] (corpo) One-time code from the Embedded Signup callback (~30s lifetime).
      # @param waba_id [String] (corpo)
      # @param phone_number_id [String, nil] (corpo) Optional — discovered from the WABA when the
      #   popup does not provide it.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def complete_official_signup(code:, waba_id:, phone_number_id: UNSET, idempotency_key: nil,
                                   timeout: nil)
        payload = compact(
          "code" => code,
          "waba_id" => waba_id,
          "phone_number_id" => phone_number_id
        )
        request("POST",
                "/official/embedded-signup",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # What is ready and what is missing, checked live against Meta. `GET /official/status`
      #
      # Joins what we store with what Meta reports right now: whether the number is verified, whether
      # the display name and the business passed review, quality and volume tier. `live` false means
      # Meta could not be reached and the values are the last known ones — the difference between
      # "this is how it is" and "we could not check" matters to the caller.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_official_status(timeout: nil)
        request("GET", "/official/status", timeout: timeout)
      end

      # Estimated Meta cost and official-rail KPIs for a period. `GET /official/insights`
      #
      # What Meta will charge the customer (bZapper charges only the subscription), estimated per
      # category — marketing, utility, authentication and service — for the period, the previous
      # period of the same length, the current month so far and its projection, plus delivery and read
      # rates, free messages, conversations from ads, marketing opt-outs, the templates sent, the most
      # common failure reasons and each number's quality and limit. The estimate uses the category and
      # `billable` flag Meta reports in each status webhook and, when missing, the template's category
      # (conservative: utility counts as charged). Prices follow the recipient's country; the rate
      # card used (Meta's, for Brazil, in BRL) comes in `rate_card`. Messages to other countries are
      # counted in `cost.other_countries` but not priced.
      #
      # @param days [Integer, nil] (query) Period ending now: 7, 30 or 90 (default 30; up to 366).
      # @param from [Time, String, nil] (query) Period start (RFC 3339). Overrides `days`.
      # @param to [Time, String, nil] (query) Period end (RFC 3339). Default: now.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_official_insights(days: nil, from: nil, to: nil, timeout: nil)
        query = {
          "days" => days,
          "from" => from,
          "to" => to
        }
        request("GET", "/official/insights", query: query, timeout: timeout)
      end

      # Upload a file to Meta once and reuse it in many sends (multipart). `POST /official/media`
      #
      # Uploads the file to Meta through the project's default number (or `instance_id`) and returns
      # its `id`. Send it as `media.id` in any media send — Meta does not download the file again for
      # each message, which is what you want for the same image in a whole campaign. The id is valid
      # for 30 days and only for sends from the number that uploaded it. Accepted (Meta's limits):
      # image JPEG/PNG up to 5 MB, sticker WebP up to 500 KB, video MP4/3GP and audio
      # AAC/AMR/MP3/MP4/OGG up to 16 MB, document PDF/Office/text up to 64 MB.
      #
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param instance_id [String, nil] (query) Number that uploads (and may send) it. Default: the
      #   project default.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def upload_official_media(file:, filename: nil, content_type: nil, instance_id: nil,
                                idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("POST",
                "/official/media",
                query: query,
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Check that a media id is still valid. `GET /official/media/{media_id}`
      #
      # Returns what Meta knows about the file (type, size, sha256). Meta's download URL is not
      # returned: it only opens with the account token, which never leaves bZapper.
      #
      # @param media_id [String] parâmetro de caminho
      # @param instance_id [String, nil] (query) Number that uploaded it. Default: the project
      #   default.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_official_media(media_id, instance_id: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET",
                "/official/media/#{segment(media_id, "media_id")}",
                query: query,
                timeout: timeout)
      end

      # Delete a media file from Meta before it expires. `DELETE /official/media/{media_id}`
      #
      # @param media_id [String] parâmetro de caminho
      # @param instance_id [String, nil] (query) Number that uploaded it. Default: the project
      #   default.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_official_media(media_id, instance_id: nil, idempotency_key: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("DELETE",
                "/official/media/#{segment(media_id, "media_id")}",
                query: query,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the raw events Meta sent for the project's accounts. `GET /official/webhook-events`
      #
      # The "Meta → bZapper" side of webhooks: each event Meta delivered for the project's business
      # accounts, exactly as Meta signed it, with how bZapper processed it (`pending`, `running`,
      # `done` or `failed`, attempts and the last error). Together with the webhook deliveries
      # (`listWebhookDeliveries`), it shows the whole chain — and, when an event does not reach your
      # system, on which side it stopped. Newest first; pass the last `id` as `before` to page back.
      # Events are kept for 3 days after being applied, 30 when they failed. Requires the
      # `webhooks:manage` scope.
      #
      # @param limit [Integer, nil] (query) 1–200 (default 50).
      # @param before [Integer, nil] (query) Return only events older than this id (pagination).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_meta_webhook_events(limit: nil, before: nil, timeout: nil)
        query = {
          "limit" => limit,
          "before" => before
        }
        request("GET", "/official/webhook-events", query: query, timeout: timeout)
      end

      # List the numbers connected to the project. `GET /official/numbers`
      #
      # Meta allows several numbers on one business account. Each connected number has an
      # `instance_id` — the same value you pass in a send to choose which number it goes out from,
      # exactly as on the unofficial rail. The one flagged `is_default` sends when the request does
      # not pick one.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_official_numbers(timeout: nil)
        request("GET", "/official/numbers", timeout: timeout)
      end

      # Connect one more number from the same business account. `POST /official/numbers`
      #
      # Reuses the authorization already stored — it belongs to the account, not to the number — so
      # nothing has to be authorized again. Pick the id from GET /official/numbers/available. The
      # number is checked against Meta before it is saved, so a wrong id fails here and not on the
      # first send.
      #
      # @param phone_number_id [String] (corpo) Meta's id of the number (`id` from GET
      #   /official/numbers/available).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def add_official_number(phone_number_id:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "phone_number_id" => phone_number_id
        )
        request("POST",
                "/official/numbers",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the account's numbers that are not connected to the project yet. `GET
      # /official/numbers/available`
      #
      # What feeds "add a number": the numbers the business account holds on Meta, minus the ones
      # already connected here — without opening Meta's dashboard.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_available_official_numbers(timeout: nil)
        request("GET", "/official/numbers/available", timeout: timeout)
      end

      # Choose the number that sends when the request does not pick one. `PUT
      # /official/numbers/{id}/default`
      #
      # @param id [String] parâmetro de caminho
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def set_default_official_number(id, idempotency_key: nil, timeout: nil)
        request("PUT",
                "/official/numbers/#{segment(id, "id")}/default",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Disconnect one number. `DELETE /official/numbers/{id}`
      #
      # The conversation history stays: the mirror instance is archived, not deleted. Removing the
      # default promotes the oldest of the remaining numbers, so the project never ends up with
      # numbers and no default.
      #
      # @param id [String] parâmetro de caminho
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def disconnect_official_number(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/official/numbers/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Read the business profile of the project's default number. `GET /official/profile`
      #
      # The business profile is what the end customer sees when opening the chat: short "about" line,
      # description, address, e-mail, sector and up to two websites. It lives on the NUMBER, not on
      # the account — with several numbers, each has its own.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_official_profile(timeout: nil)
        request("GET", "/official/profile", timeout: timeout)
      end

      # Update the business profile of the project's default number. `PUT /official/profile`
      #
      # Validated against Meta's published limits BEFORE sending (about 139 characters, description
      # 512, address 256, at most 2 websites, a closed list of sectors), so a refusal names the field
      # and by how much it overflowed instead of Meta's generic "Invalid parameter". Send the WHOLE
      # profile: an empty field is not "unchanged", it clears that field on Meta. Read it first with
      # GET and send it back with your edits.
      #
      # @param about [String, nil] (corpo) Short line under the name.
      # @param description [String, nil] (corpo)
      # @param address [String, nil] (corpo)
      # @param email [String, nil] (corpo)
      # @param vertical [String, nil] (corpo) Business sector (closed list defined by Meta).
      # @param websites [Array<String>, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def update_official_profile(about: UNSET, description: UNSET, address: UNSET, email: UNSET,
                                  vertical: UNSET, websites: UNSET, idempotency_key: nil,
                                  timeout: nil)
        payload = compact(
          "about" => about,
          "description" => description,
          "address" => address,
          "email" => email,
          "vertical" => vertical,
          "websites" => websites
        )
        request("PUT",
                "/official/profile",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Replace the profile photo of the project's default number (multipart, JPEG/PNG up to 5 MB).
      # `POST /official/profile/photo`
      #
      # Uploads the image to Meta and sets it as the profile photo in one call. WhatsApp Business has
      # only the round profile photo — there is no cover image. Meta recommends 640x640.
      #
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def upload_official_profile_photo(file:, filename: nil, content_type: nil,
                                        idempotency_key: nil, timeout: nil)
        request("POST",
                "/official/profile/photo",
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Re-register the project's default number on the Cloud API. `POST /official/profile/reregister`
      #
      # The step people forget after Meta approves a new display name: until the number is
      # re-registered it keeps showing the old name. Requesting the name change itself is not an API
      # call (it is done in WhatsApp Manager); this is the half that is. Already registered counts as
      # success.
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def reregister_official_profile(idempotency_key: nil, timeout: nil)
        request("POST",
                "/official/profile/reregister",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Read the business profile of the number given in the path. `GET
      # /official/numbers/{id}/profile`
      #
      # The business profile is what the end customer sees when opening the chat: short "about" line,
      # description, address, e-mail, sector and up to two websites. It lives on the NUMBER, not on
      # the account — with several numbers, each has its own.
      #
      # @param id [String] Connected number id (`id` from GET /official/numbers).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_official_number_profile(id, timeout: nil)
        request("GET", "/official/numbers/#{segment(id, "id")}/profile", timeout: timeout)
      end

      # Update the business profile of the number given in the path. `PUT
      # /official/numbers/{id}/profile`
      #
      # Validated against Meta's published limits BEFORE sending (about 139 characters, description
      # 512, address 256, at most 2 websites, a closed list of sectors), so a refusal names the field
      # and by how much it overflowed instead of Meta's generic "Invalid parameter". Send the WHOLE
      # profile: an empty field is not "unchanged", it clears that field on Meta. Read it first with
      # GET and send it back with your edits.
      #
      # @param id [String] Connected number id (`id` from GET /official/numbers).
      # @param about [String, nil] (corpo) Short line under the name.
      # @param description [String, nil] (corpo)
      # @param address [String, nil] (corpo)
      # @param email [String, nil] (corpo)
      # @param vertical [String, nil] (corpo) Business sector (closed list defined by Meta).
      # @param websites [Array<String>, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_official_number_profile(id, about: UNSET, description: UNSET, address: UNSET,
                                         email: UNSET, vertical: UNSET, websites: UNSET,
                                         idempotency_key: nil, timeout: nil)
        payload = compact(
          "about" => about,
          "description" => description,
          "address" => address,
          "email" => email,
          "vertical" => vertical,
          "websites" => websites
        )
        request("PUT",
                "/official/numbers/#{segment(id, "id")}/profile",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Replace the profile photo of the number given in the path (multipart, JPEG/PNG up to 5 MB).
      # `POST /official/numbers/{id}/profile/photo`
      #
      # Uploads the image to Meta and sets it as the profile photo in one call. WhatsApp Business has
      # only the round profile photo — there is no cover image. Meta recommends 640x640.
      #
      # @param id [String] Connected number id (`id` from GET /official/numbers).
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def upload_official_number_profile_photo(id, file:, filename: nil, content_type: nil,
                                               idempotency_key: nil, timeout: nil)
        request("POST",
                "/official/numbers/#{segment(id, "id")}/profile/photo",
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Re-register the number given in the path on the Cloud API. `POST
      # /official/numbers/{id}/profile/reregister`
      #
      # The step people forget after Meta approves a new display name: until the number is
      # re-registered it keeps showing the old name. Requesting the name change itself is not an API
      # call (it is done in WhatsApp Manager); this is the half that is. Already registered counts as
      # success.
      #
      # @param id [String] Connected number id (`id` from GET /official/numbers).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def reregister_official_number_profile(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/official/numbers/#{segment(id, "id")}/profile/reregister",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
