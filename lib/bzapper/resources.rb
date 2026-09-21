# frozen_string_literal: true

# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.

require_relative "resources/base"
require_relative "resources/accounts"
require_relative "resources/contacts"
require_relative "resources/usage"
require_relative "resources/billing"
require_relative "resources/advanced"
require_relative "resources/conversations"
require_relative "resources/instances"
require_relative "resources/groups"
require_relative "resources/system"
require_relative "resources/messages"
require_relative "resources/scheduling"
require_relative "resources/campaigns"
require_relative "resources/advisories"
require_relative "resources/webhooks"
require_relative "resources/pools"
require_relative "resources/connect"
require_relative "resources/partner"

module Bzapper
  # Os recursos do {Client} (um por tag da spec). Incluído no {Client}.
  # @api private
  module ResourceAccessors
    # @return [Resources::Accounts] Conta, perfil, chaves de API, marca, projetos e usuários.
    attr_reader :accounts

    # @return [Resources::Contacts] Contatos (CRM), tags, grupos de contatos, opt-in/out, supressões e checagem.
    attr_reader :contacts

    # @return [Resources::Usage] Uso medido (consumo).
    attr_reader :usage

    # @return [Resources::Billing] Cobrança: plano, assinatura, add-ons, faturas e preços.
    attr_reader :billing

    # @return [Resources::Advanced] Recursos avançados: editar/apagar/encaminhar, perfil, privacidade, chats, etiquetas, bloqueio e chamadas.
    attr_reader :advanced

    # @return [Resources::Conversations] Conversas (inbox) e histórico.
    attr_reader :conversations

    # @return [Resources::Instances] Números (instâncias): conexão, QR, sessão, proxy, filtros de entrada e conta oficial.
    attr_reader :instances

    # @return [Resources::Groups] Grupos do WhatsApp: info, participantes, convite, prévia e pedidos de entrada.
    attr_reader :groups

    # @return [Resources::System] Saúde e meta.
    attr_reader :system

    # @return [Resources::Messages] Envio de mensagens (todos os tipos, OTP), presença e confirmação de leitura.
    attr_reader :messages

    # @return [Resources::Scheduling] Envios agendados.
    attr_reader :scheduling

    # @return [Resources::Campaigns] Campanhas: estimativa, destinatários, simulação e controle.
    attr_reader :campaigns

    # @return [Resources::Advisories] Avisos "atualize sua integração".
    attr_reader :advisories

    # @return [Resources::Webhooks] Webhooks de eventos (gestão, teste, entregas).
    attr_reader :webhooks

    # @return [Resources::Pools] Pools de números (rotação).
    attr_reader :pools

    # @return [Resources::Connect] bZapper Connect do lado do CLIENTE: apps parceiros conectados à conta.
    attr_reader :connect

    # Nomes dos recursos, na ordem da spec.
    RESOURCES = %i[accounts contacts usage billing advanced conversations instances groups system messages scheduling campaigns advisories webhooks pools connect].freeze

    private

    def build_resources(transport)
      @accounts = Resources::Accounts.new(transport)
      @contacts = Resources::Contacts.new(transport)
      @usage = Resources::Usage.new(transport)
      @billing = Resources::Billing.new(transport)
      @advanced = Resources::Advanced.new(transport)
      @conversations = Resources::Conversations.new(transport)
      @instances = Resources::Instances.new(transport)
      @groups = Resources::Groups.new(transport)
      @system = Resources::System.new(transport)
      @messages = Resources::Messages.new(transport)
      @scheduling = Resources::Scheduling.new(transport)
      @campaigns = Resources::Campaigns.new(transport)
      @advisories = Resources::Advisories.new(transport)
      @webhooks = Resources::Webhooks.new(transport)
      @pools = Resources::Pools.new(transport)
      @connect = Resources::Connect.new(transport)
    end
  end
end
