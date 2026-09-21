# frozen_string_literal: true

# SDK oficial em Ruby da API do bZapper (WhatsApp): mensagens, números, grupos, contatos,
# campanhas, webhooks e o bZapper Connect. Só biblioteca padrão (net/http, json, openssl,
# securerandom).
#
# @example
#   require "bzapper"
#
#   client = Bzapper::Client.new(ENV.fetch("BZAPPER_API_KEY"))
#   client.messages.send_text(to: "5511999990000", body: "Olá!")
module Bzapper
end

require "json"
require "net/http"
require "openssl"
require "securerandom"
require "time"
require "uri"

require_relative "bzapper/version"
require_relative "bzapper/unset"
require_relative "bzapper/errors"
require_relative "bzapper/codec"
require_relative "bzapper/upload"
require_relative "bzapper/transport"
require_relative "bzapper/resources"
require_relative "bzapper/client"
require_relative "bzapper/webhook"
