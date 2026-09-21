# frozen_string_literal: true

# Apoio dos testes: servidor HTTP falso (stdlib) e localização dos casos de conformidade.
#
# Os casos moram em `clients/conformance/cases.json` no monorepo (gerados de
# `packages/sdk/openapi.yaml`). O espelho público (`bernisoftware/bzapper-ruby`) recebe só
# `clients/ruby` — por isso existe a cópia `test/fixtures/conformance/cases.json`, escrita pelo
# `clients/conformance/generate.py` (não edite à mão). A suíte lê a cópia; um teste trava que
# ela seja idêntica à fonte quando as duas existem (no monorepo).

require "json"
require "minitest/autorun"
require "bzapper"

require_relative "support/fake_server"

module TestSupport
  ROOT = File.expand_path("..", __dir__) # clients/ruby (ou a raiz do espelho público)
  VENDORED_CASES = File.join(ROOT, "test", "fixtures", "conformance", "cases.json")
  # No monorepo: <raiz>/clients/ruby. Fora dele (espelho, container) estes caminhos não
  # existem e os testes que dependem deles são pulados.
  MONOREPO_CASES = File.expand_path("../conformance/cases.json", ROOT)
  MONOREPO_SPEC = File.expand_path("../../packages/sdk/openapi.yaml", ROOT)
  # CI do espelho: roda a suíte de novo contra a gem INSTALADA (não o ./lib).
  AGAINST_GEM = ENV["BZAPPER_TEST_AGAINST_GEM"] == "1"

  def self.read_json(path)
    JSON.parse(File.binread(path).force_encoding(Encoding::UTF_8))
  end

  def self.cases
    @cases ||= read_json(VENDORED_CASES)
  end

  def self.server
    @server ||= FakeServer.new.tap { |srv| Minitest.after_run { srv.stop } }
  end

  # Resposta de sucesso (JSON do recurso, como a API devolve).
  def self.ok(body, status: 200, headers: {})
    { "status" => status, "headers" => headers, "body" => body }
  end

  # Resposta de erro no formato da API: `{code, message, locale}`.
  def self.fail_with(status, code, headers = {}, message: nil)
    {
      "status" => status,
      "headers" => headers,
      "body" => { "code" => code, "message" => message || code, "locale" => "pt-BR" }
    }
  end

  def self.json_body(record)
    raw = record[:body]
    raw.empty? ? nil : JSON.parse(raw.dup.force_encoding(Encoding::UTF_8))
  end
end

if TestSupport::AGAINST_GEM
  loaded = $LOADED_FEATURES.find { |path| path.end_with?("/bzapper.rb") }
  if loaded.nil? || loaded.start_with?(File.join(TestSupport::ROOT, "lib"))
    abort "BZAPPER_TEST_AGAINST_GEM=1, mas o bzapper foi carregado de #{loaded.inspect} (não da gem instalada)"
  end
  puts "bzapper carregado da gem instalada: #{loaded}"
end

# Base dos testes que falam com o servidor falso.
class ServerTestCase < Minitest::Test
  def server
    TestSupport.server
  end

  def requests
    server.requests
  end

  def client(responses, **options)
    server.reset(responses)
    @sleeps = []
    sleeps = @sleeps
    Bzapper::Client.new("bz_live_unit", base_url: server.base_url,
                                        sleeper: ->(seconds) { sleeps << seconds }, **options)
  end

  def partner(responses, **options)
    server.reset(responses)
    Bzapper::PartnerClient.new("bz_partner_unit", base_url: server.base_url, sleeper: ->(_s) {}, **options)
  end

  def ok(body, **kwargs)
    TestSupport.ok(body, **kwargs)
  end

  def fail_with(status, code, headers = {}, **kwargs)
    TestSupport.fail_with(status, code, headers, **kwargs)
  end

  def json_body(record)
    TestSupport.json_body(record)
  end
end
