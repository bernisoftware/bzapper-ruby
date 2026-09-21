# frozen_string_literal: true

# A versão vem de Bzapper::VERSION (lib/bzapper/version.rb) — o scripts/release-sdks.sh bumpa só
# aquela linha. Não escreva o número aqui.
require_relative "lib/bzapper/version"

Gem::Specification.new do |spec|
  spec.name = "bzapper"
  spec.version = Bzapper::VERSION
  spec.authors = ["Berni Software"]
  spec.summary = "SDK oficial da API do bZapper (WhatsApp)"
  spec.description = "Mensagens (todos os tipos, OTP), números e QR, grupos, contatos, campanhas, " \
                     "webhooks com verificação de assinatura e bZapper Connect. Zero dependências " \
                     "de runtime, novas tentativas e idempotência automáticas."
  spec.homepage = "https://bzapper.com.br"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/bernisoftware/bzapper-ruby",
    "bug_tracker_uri" => "https://github.com/bernisoftware/bzapper-ruby/issues",
    "documentation_uri" => "https://github.com/bernisoftware/bzapper-ruby#readme"
  }

  # Só o que o usuário precisa: código, README e licença (testes, script e CI ficam no repositório).
  spec.files = Dir.chdir(__dir__) { Dir["lib/**/*.rb"].sort + %w[README.md LICENSE] }
  spec.require_paths = ["lib"]
end
