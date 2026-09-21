# frozen_string_literal: true

# A versão existe em dois lugares — `lib/bzapper/version.rb` e o gemspec (que lê
# `Bzapper::VERSION`) — e vai no header `X-Bzapper-Client` de TODA requisição: é por ele que a
# API sabe quem avisar quando uma correção exige atualizar a SDK. Se ele congelar (a SDK Go do
# bZapper ficou em 0.5.0 por releases seguidas), o aviso vai para o alvo errado.

require "test_helper"

class VersionTest < ServerTestCase
  VERSION_RB = File.join(TestSupport::ROOT, "lib", "bzapper", "version.rb")
  GEMSPEC = File.join(TestSupport::ROOT, "bzapper.gemspec")
  # O MESMO padrão do scripts/release-sdks.sh — `(?m)^(\s*VERSION\s*=\s*")([^"]+)(")` em Python
  # (em Ruby, `^` já é começo de linha). Se não casar, o bump não acontece; se casar num
  # comentário, o bump muda o comentário e a constante congela.
  RELEASE_RE = /^(\s*VERSION\s*=\s*")([^"]+)(")/.freeze

  def test_formato_da_versao
    assert_match(/\A\d+\.\d+\.\d+\z/, Bzapper::VERSION)
  end

  def test_padrao_do_release_casa_em_version_rb
    text = File.read(VERSION_RB, encoding: "UTF-8")
    match = RELEASE_RE.match(text) # como o `re.search` do release: a 1ª ocorrência é o alvo
    refute_nil match, "o padrão do release-sdks.sh não casa em lib/bzapper/version.rb"
    assert_equal Bzapper::VERSION, match[2]
    assert_equal 1, text.scan(RELEASE_RE).size, 'uma única linha VERSION = "..." em lib/bzapper/version.rb'

    # Simula o bump do release e avalia o resultado: a versão nova precisa aparecer na
    # CONSTANTE (e não num comentário que por acaso tenha o mesmo formato).
    bumped = text[0...match.begin(0)] + match[1] + "9.8.7" + match[3] + text[match.end(0)..]
    sandbox = Module.new
    sandbox.module_eval(bumped, VERSION_RB)
    assert_equal "9.8.7", sandbox.const_get(:Bzapper, false).const_get(:VERSION, false)
  end

  def test_gemspec_le_a_constante
    source = File.read(GEMSPEC, encoding: "UTF-8")
    assert_includes source, "spec.version = Bzapper::VERSION"
    refute_match(/spec\.version\s*=\s*["']/, source, "o gemspec não pode fixar o número")

    if TestSupport::AGAINST_GEM
      # Rodando contra a gem instalada: a versão dela é a do código carregado.
      assert_equal Bzapper::VERSION, Gem.loaded_specs.fetch("bzapper").version.to_s
      return
    end

    spec = Gem::Specification.load(GEMSPEC)
    assert_equal Bzapper::VERSION, spec.version.to_s
    assert_equal "bzapper", spec.name
    assert_equal Gem::Requirement.new(">= 3.0"), spec.required_ruby_version
    assert_empty spec.runtime_dependencies, "zero dependência de runtime"
    assert_equal "MIT", spec.license
    refute spec.metadata.key?("rubygems_mfa_required"), "rubygems_mfa_required trava o gem push do CI"
    extra = spec.files.reject { |f| f.start_with?("lib/") || %w[README.md LICENSE].include?(f) }
    assert_empty extra, "a gem leva só lib/, README.md e LICENSE"
    assert_includes spec.files, "lib/bzapper.rb"
    assert_includes spec.files, "lib/bzapper/version.rb"
  end

  def test_versao_igual_a_do_release_json
    release = File.expand_path("../release.json", TestSupport::ROOT)
    skip "release.json só existe no monorepo" unless File.file?(release)

    data = TestSupport.read_json(release)
    version = data["version"] || data.dig("sdks", "ruby")
    skip "release.json sem versão legível" unless version.is_a?(String)
    assert_equal version, Bzapper::VERSION
  end

  def test_identificacao_do_cliente
    assert_equal "bzapper-ruby/#{Bzapper::VERSION}", Bzapper::CLIENT_ID
    assert_match %r{\Abzapper-ruby/\d+\.\d+\.\d+\z}, Bzapper::CLIENT_ID
  end

  def test_header_vai_em_toda_requisicao
    bz = client([ok({ "data" => [] }), { "status" => 204, "headers" => {}, "body" => nil }])
    bz.instances.list_instances
    bz.webhooks.delete_webhook("w1")
    assert_equal 2, requests.size
    requests.each do |record|
      assert_equal "bzapper-ruby/#{Bzapper::VERSION}", record[:headers]["x-bzapper-client"]
      assert_equal "bzapper-ruby/#{Bzapper::VERSION}", record[:headers]["user-agent"]
    end
  end
end
