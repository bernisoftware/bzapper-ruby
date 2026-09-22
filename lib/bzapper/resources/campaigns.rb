# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Campanhas: estimativa, destinatários, simulação e controle — `client.campaigns`.
    class Campaigns < Base
      # List campaigns. `GET /campaigns`
      #
      # @param limit [Integer, nil] (query) Max items.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_campaigns(limit: nil, timeout: nil)
        query = {
          "limit" => limit
        }
        request("GET", "/campaigns", query: query, timeout: timeout)
      end

      # Create a campaign. `POST /campaigns`
      #
      # Requires the Pro plan and the Campaigns add-on.
      #
      # @param name [String, nil] (corpo)
      # @param pool_id [String, nil] (corpo) Restrict to a pool (else all project numbers).
      # @param pacing_profile [String, nil] (corpo)
      # @param start_at [Time, String, nil] (corpo) Future start = scheduled campaign.
      # @param variations [Array<Hash>] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_campaign(variations:, name: UNSET, pool_id: UNSET, pacing_profile: UNSET,
                          start_at: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "pool_id" => pool_id,
          "pacing_profile" => pacing_profile,
          "start_at" => start_at,
          "variations" => variations
        )
        request("POST",
                "/campaigns",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Estimate send duration (live). `GET /campaigns/estimate`
      #
      # Given a recipient count and pacing, returns eligible numbers and the estimated duration —
      # powers the builder's real-time panel. No campaign needed.
      #
      # @param recipients [Integer, nil] (query) Number of recipients.
      # @param pacing [String, nil] (query)
      # @param pool_id [String, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def estimate_campaign(recipients: nil, pacing: nil, pool_id: nil, timeout: nil)
        query = {
          "recipients" => recipients,
          "pacing" => pacing,
          "pool_id" => pool_id
        }
        request("GET", "/campaigns/estimate", query: query, timeout: timeout)
      end

      # Per-number campaign eligibility (connection + warm-up). `GET /campaigns/eligibility`
      #
      # Same engine the dispatcher uses: which numbers can send campaigns now, the account's anti-ban
      # policy (warm-up days, minimum numbers) and whether a campaign can be started.
      #
      # @param pool_id [String, nil] (query) Restrict to a pool.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_campaign_eligibility(pool_id: nil, timeout: nil)
        query = {
          "pool_id" => pool_id
        }
        request("GET", "/campaigns/eligibility", query: query, timeout: timeout)
      end

      # Upload the header image. `POST /campaigns/media`
      #
      # Uploads a header image (PNG/JPEG/WebP, up to 5 MB) and returns a public URL to use as the
      # variation media.
      #
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def upload_campaign_media(file:, filename: nil, content_type: nil, idempotency_key: nil,
                                timeout: nil)
        request("POST",
                "/campaigns/media",
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Get a campaign with stats and variations. `GET /campaigns/{id}`
      #
      # @param id [String] Campaign ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_campaign(id, timeout: nil)
        request("GET", "/campaigns/#{segment(id, "id")}", timeout: timeout)
      end

      # Edit a not-yet-started campaign. `PATCH /campaigns/{id}`
      #
      # Updates name, pacing, schedule and (if sent) replaces the variations. Only allowed while
      # draft/scheduled — 409 once started.
      #
      # @param id [String] Campaign ID (UUID).
      # @param name [String, nil] (corpo)
      # @param pacing_profile [String, nil] (corpo)
      # @param start_at [Time, String, nil] (corpo) Future start = scheduled campaign.
      # @param variations [Array<Hash>, nil] (corpo) When sent (non-empty), REPLACES all variations.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_campaign(id, name: UNSET, pacing_profile: UNSET, start_at: UNSET,
                          variations: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "pacing_profile" => pacing_profile,
          "start_at" => start_at,
          "variations" => variations
        )
        request("PATCH",
                "/campaigns/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List recipients with per-contact delivery. `GET /campaigns/{id}/recipients`
      #
      # @param id [String] Campaign ID (UUID).
      # @param limit [Integer, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def list_campaign_recipients(id, limit: nil, timeout: nil)
        query = {
          "limit" => limit
        }
        request("GET", "/campaigns/#{segment(id, "id")}/recipients", query: query, timeout: timeout)
      end

      # Add (or replace) recipients. `POST /campaigns/{id}/recipients`
      #
      # @param id [String] Campaign ID (UUID).
      # @param recipients [Array<Hash>, nil] (corpo)
      # @param contacts [Hash, nil] (corpo) Map of phone → payload, e.g. {"+5551999198087": {"name":
      #   "Vinicius"}}.
      # @param contact_ids [Array<String>, nil] (corpo) Explicitly selected contact ids (only the
      #   active ones are added).
      # @param contact_filter [Hash, nil] (corpo) Add every ACTIVE contact matching this filter.
      # @param replace [Boolean, nil] (corpo) Replace the whole recipient list instead of appending
      #   (clears first). Only allowed while the campaign is draft/scheduled.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def add_campaign_recipients(id, recipients: UNSET, contacts: UNSET, contact_ids: UNSET,
                                  contact_filter: UNSET, replace: UNSET, idempotency_key: nil,
                                  timeout: nil)
        payload = compact(
          "recipients" => recipients,
          "contacts" => contacts,
          "contact_ids" => contact_ids,
          "contact_filter" => contact_filter,
          "replace" => replace
        )
        request("POST",
                "/campaigns/#{segment(id, "id")}/recipients",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Start (or schedule) a campaign. `POST /campaigns/{id}/start`
      #
      # @param id [String] Campaign ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def start_campaign(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/campaigns/#{segment(id, "id")}/start",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Pause a campaign. `POST /campaigns/{id}/pause`
      #
      # @param id [String] Campaign ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def pause_campaign(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/campaigns/#{segment(id, "id")}/pause",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Resume a campaign. `POST /campaigns/{id}/resume`
      #
      # @param id [String] Campaign ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def resume_campaign(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/campaigns/#{segment(id, "id")}/resume",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Cancel a campaign. `POST /campaigns/{id}/cancel`
      #
      # @param id [String] Campaign ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def cancel_campaign(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/campaigns/#{segment(id, "id")}/cancel",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Simulate a campaign without sending. `POST /campaigns/{id}/dry-run`
      #
      # @param id [String] Campaign ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def dry_run_campaign(id, idempotency_key: nil, timeout: nil)
        request("POST",
                "/campaigns/#{segment(id, "id")}/dry-run",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
