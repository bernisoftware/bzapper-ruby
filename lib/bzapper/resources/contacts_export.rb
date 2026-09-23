# frozen_string_literal: true

# ESCRITO À MÃO (não sai do script/generate.rb): `exportContacts` responde `text/csv`, e não
# JSON — está fora dos casos gerados (BRIEF §6, "CSV") e tem teste próprio
# (test/unit_test.rb, CsvExportTest). O resto do `client.contacts` é gerado
# (lib/bzapper/resources/contacts.rb).

module Bzapper
  module Resources
    class Contacts
      # Export contacts as CSV. `GET /contacts/export`
      #
      # Devolve a base de contatos em **CSV** (`text/csv`, `Content-Disposition: attachment`) —
      # não é JSON. Colunas:
      # `phone,name,email,status,source,tags,groups,created_at,last_activity_at`; tags e grupos
      # vêm unidos por `;` e os instantes em RFC 3339 UTC. Os filtros são os MESMOS do
      # {#list_contacts} (só não há `offset`: use `limit` para limitar as linhas).
      #
      # O retorno é o texto do CSV, como veio do servidor (UTF-8) — passe-o a `CSV.parse` ou
      # grave em disco. Para não carregar tudo na memória, exporte em fatias com os filtros
      # (`created_after`/`created_before`, `limit`).
      #
      # @example Gravar em disco
      #   File.write("contatos.csv", client.contacts.export_contacts(status: "active"))
      #
      # @example Ler linha a linha
      #   require "csv"
      #   CSV.parse(client.contacts.export_contacts(tags: %w[vip]), headers: true) do |row|
      #     puts row["phone"]
      #   end
      #
      # @param search [String, nil] (query) Filter by name, phone, email or document.
      # @param tags [Array<String>, nil] (query) Tag keys (repeat the param or a CSV list).
      # @param tags_match [String, nil] (query) Match ANY (default) or ALL of `tags`.
      # @param groups [Array<String>, nil] (query) Contact-group keys.
      # @param project_id [String, nil] (query) Scope by project (alternative to the X-Project-Id
      #   header).
      # @param instance_id [String, nil] (query) Filter by a number (instance) the contact
      #   interacted with.
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
      # @param limit [Integer, nil] (query) Cap of exported rows.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [String] o CSV cru (UTF-8), com o cabeçalho na primeira linha.
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def export_contacts(search: nil, tags: nil, tags_match: nil, groups: nil, project_id: nil,
                          instance_id: nil, status: nil, city: nil, state: nil, country: nil,
                          zip: nil, document: nil, has_email: nil, last_activity_after: nil,
                          last_activity_before: nil, created_after: nil, created_before: nil,
                          sort: nil, limit: nil, timeout: nil)
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
          "limit" => limit
        }
        request_text("GET", "/contacts/export", query: query, timeout: timeout)
      end
    end
  end
end
