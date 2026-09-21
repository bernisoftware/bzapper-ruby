# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

module Bzapper
  module Resources
    # Conversas (inbox) e histórico — `client.conversations`.
    class Conversations < Base
      # List inbox threads (all numbers, or one with instance_id). `GET /conversations`
      #
      # @param instance_id [String, nil] (query) Restrict to one number. Omit for the unified inbox
      #   across all numbers.
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      def list_conversations(instance_id: nil, timeout: nil)
        query = {
          "instance_id" => instance_id
        }
        request("GET", "/conversations", query: query, timeout: timeout)
      end

      # Paginated history of a chat. `GET /conversations/{jid}/messages`
      #
      # @param jid [String] chat_jid of the contact/group.
      # @param instance_id [String, nil] (query) Restrict to one number. Omit for the history across
      #   all numbers.
      # @param before [Time, String, nil] (query) Returns messages before this instant (RFC3339).
      # @param limit [Integer, nil] (query)
      # @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente).
      # @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204).
      # @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede.
      # @raise [ArgumentError] parâmetro de caminho vazio, "." ou "..".
      def conversation_history(jid, instance_id: nil, before: nil, limit: nil, timeout: nil)
        query = {
          "instance_id" => instance_id,
          "before" => before,
          "limit" => limit
        }
        request("GET",
                "/conversations/#{segment(jid, "jid")}/messages",
                query: query,
                timeout: timeout)
      end
    end
  end
end
