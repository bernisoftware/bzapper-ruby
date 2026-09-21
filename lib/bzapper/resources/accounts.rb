# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Conta, perfil, chaves de API, marca, projetos e usuários — `client.accounts`.
    class Accounts < Base
      # List the tenant's API keys (without the raw key). `GET /keys`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_my_keys(timeout: nil)
        request("GET", "/keys", timeout: timeout)
      end

      # Generate a tenant API key (raw key shown only once). Admin only — an agent key/user gets 403
      # admin_required. `POST /keys`
      #
      # @param name [String, nil] (corpo)
      # @param role [String, nil] (corpo) Role of the key/user (super_admin is via the admin token).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_my_key(name: UNSET, role: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "role" => role
        )
        request("POST", "/keys", body: payload, idempotency_key: idempotency_key, timeout: timeout)
      end

      # Revoke a tenant API key. Admin only. `DELETE /keys/{id}`
      #
      # @param id [String] Instance ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def revoke_my_key(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/keys/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Authenticated identity (+ profile when it's a user session). `GET /me`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_me(timeout: nil)
        request("GET", "/me", timeout: timeout)
      end

      # Update the user profile (name/phone/job title). `PATCH /me`
      #
      # @param name [String, nil] (corpo)
      # @param phone [String, nil] (corpo) Stored as +DDIdigits.
      # @param job_title [String, nil] (corpo)
      # @param locale [String, nil] (corpo) UI language to persist on the account (e.g. pt-BR). Empty
      #   = unchanged.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def update_profile(name: UNSET, phone: UNSET, job_title: UNSET, locale: UNSET,
                         idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "phone" => phone,
          "job_title" => job_title,
          "locale" => locale
        )
        request("PATCH", "/me", body: payload, idempotency_key: idempotency_key, timeout: timeout)
      end

      # Shared identity of the numbers (brand kit + "About"). `GET /brand`
      #
      # Returns the tenant identity. Only `about` is applicable to the WhatsApp profile; each number's
      # profile name and photo are set by the customer on their own phone when pairing the number
      # (WhatsApp does not allow a linked device to change them).
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_brand(timeout: nil)
        request("GET", "/brand", timeout: timeout)
      end

      # Update the shared identity. `PUT /brand`
      #
      # @param about [String, nil] (corpo) "About"/status — applied to all numbers.
      # @param display_name [String, nil] (corpo) Business name (kit).
      # @param logo_url [String, nil] (corpo) Logo URL (kit).
      # @param website [String, nil] (corpo)
      # @param email [String, nil] (corpo)
      # @param phone [String, nil] (corpo) Contact phone in E.164 (+DDIdigits).
      # @param address [String, nil] (corpo)
      # @param description [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def set_brand(about: UNSET, display_name: UNSET, logo_url: UNSET, website: UNSET,
                    email: UNSET, phone: UNSET, address: UNSET, description: UNSET,
                    idempotency_key: nil, timeout: nil)
        payload = compact(
          "about" => about,
          "display_name" => display_name,
          "logo_url" => logo_url,
          "website" => website,
          "email" => email,
          "phone" => phone,
          "address" => address,
          "description" => description
        )
        request("PUT", "/brand", body: payload, idempotency_key: idempotency_key, timeout: timeout)
      end

      # Apply the "About" to ALL connected numbers. `POST /brand/apply`
      #
      # Pushes the `about` (status message) to all of the tenant's connected numbers. Returns how many
      # were applied, the skipped ones (disconnected) and the total.
      #
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def apply_brand(idempotency_key: nil, timeout: nil)
        request("POST", "/brand/apply", idempotency_key: idempotency_key, timeout: timeout)
      end

      # Upload the brand logo (multipart) → DO Spaces. `POST /brand/logo`
      #
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def upload_brand_logo(file:, filename: nil, content_type: nil, idempotency_key: nil,
                            timeout: nil)
        request("POST",
                "/brand/logo",
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the account's projects. `GET /projects`
      #
      # Projects isolate numbers, inbox, API keys and statistics. Each API key belongs to ONE project;
      # in the dashboard, the active project goes in the `X-Project-Id` header.
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_projects(timeout: nil)
        request("GET", "/projects", timeout: timeout)
      end

      # Create a project (admin). `POST /projects`
      #
      # @param name [String] (corpo)
      # @param api_mode [String, nil] (corpo) Rail of the project: UNOFFICIAL (QR-paired numbers) or
      #   OFFICIAL (WhatsApp Cloud API). Immutable after creation.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def create_project(name:, api_mode: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name,
          "api_mode" => api_mode
        )
        request("POST",
                "/projects",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Number status per project (traffic light). `GET /projects/health`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def get_projects_health(timeout: nil)
        request("GET", "/projects/health", timeout: timeout)
      end

      # Update a project (admin). `PATCH /projects/{id}`
      #
      # `api_mode` is immutable and is ignored here.
      #
      # @param id [String] Resource ID (UUID).
      # @param name [String] (corpo)
      # @param logo_url [String, nil] (corpo)
      # @param color [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_project(id, name:, logo_url: UNSET, color: UNSET, idempotency_key: nil,
                         timeout: nil)
        payload = compact(
          "name" => name,
          "logo_url" => logo_url,
          "color" => color
        )
        request("PATCH",
                "/projects/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Delete a project (admin). `DELETE /projects/{id}`
      #
      # @param id [String] Resource ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def delete_project(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/projects/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Identity of the numbers of a specific project. `GET /projects/{id}/brand`
      #
      # @param id [String] Resource ID (UUID).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def get_project_brand(id, timeout: nil)
        request("GET", "/projects/#{segment(id, "id")}/brand", timeout: timeout)
      end

      # Save the identity of a specific project's numbers (admin). `PUT /projects/{id}/brand`
      #
      # @param id [String] Resource ID (UUID).
      # @param about [String, nil] (corpo) "About"/status — applied to all numbers.
      # @param display_name [String, nil] (corpo) Business name (kit).
      # @param logo_url [String, nil] (corpo) Logo URL (kit).
      # @param website [String, nil] (corpo)
      # @param email [String, nil] (corpo)
      # @param phone [String, nil] (corpo) Contact phone in E.164 (+DDIdigits).
      # @param address [String, nil] (corpo)
      # @param description [String, nil] (corpo)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def set_project_brand(id, about: UNSET, display_name: UNSET, logo_url: UNSET, website: UNSET,
                            email: UNSET, phone: UNSET, address: UNSET, description: UNSET,
                            idempotency_key: nil, timeout: nil)
        payload = compact(
          "about" => about,
          "display_name" => display_name,
          "logo_url" => logo_url,
          "website" => website,
          "email" => email,
          "phone" => phone,
          "address" => address,
          "description" => description
        )
        request("PUT",
                "/projects/#{segment(id, "id")}/brand",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Upload the project logo (multipart, PNG/JPEG/WebP up to 5 MB) — admin. `POST
      # /projects/{id}/logo`
      #
      # @param id [String] Resource ID (UUID).
      # @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco.
      # @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão "file").
      # @param content_type [String, nil] tipo MIME (padrão: application/octet-stream).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def upload_project_logo(id, file:, filename: nil, content_type: nil, idempotency_key: nil,
                              timeout: nil)
        request("POST",
                "/projects/#{segment(id, "id")}/logo",
                multipart: upload("file", file, filename, content_type),
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # List the account's users. `GET /users`
      #
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_users(timeout: nil)
        request("GET", "/users", timeout: timeout)
      end

      # Invite a user (admin). `POST /users`
      #
      # Creates the user in the account with the given role and sends a link to set the password.
      #
      # @param email [String] (corpo)
      # @param name [String, nil] (corpo)
      # @param role [String, nil] (corpo) agent = member (no billing)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def invite_user(email:, name: UNSET, role: UNSET, idempotency_key: nil, timeout: nil)
        payload = compact(
          "email" => email,
          "name" => name,
          "role" => role
        )
        request("POST", "/users", body: payload, idempotency_key: idempotency_key, timeout: timeout)
      end

      # Change a user's role (admin). `PATCH /users/{id}`
      #
      # Demoting the last administrator of the account is refused (409 last_admin).
      #
      # @param id [String] Resource ID (UUID).
      # @param role [String] (corpo) agent = member (no billing)
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def update_user_role(id, role:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "role" => role
        )
        request("PATCH",
                "/users/#{segment(id, "id")}",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Remove a user from the account (admin). `DELETE /users/{id}`
      #
      # You cannot remove yourself (409 self_remove) nor the last administrator (409 last_admin).
      #
      # @param id [String] Resource ID (UUID).
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def remove_user(id, idempotency_key: nil, timeout: nil)
        request("DELETE",
                "/users/#{segment(id, "id")}",
                idempotency_key: idempotency_key,
                timeout: timeout)
      end

      # Rename the account (company name) — admin. `PATCH /account`
      #
      # @param name [String] (corpo) Company name.
      # @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma).
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def update_account(name:, idempotency_key: nil, timeout: nil)
        payload = compact(
          "name" => name
        )
        request("PATCH",
                "/account",
                body: payload,
                idempotency_key: idempotency_key,
                timeout: timeout)
      end
    end
  end
end
