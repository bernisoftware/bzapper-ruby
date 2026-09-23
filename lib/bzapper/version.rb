# frozen_string_literal: true

module Bzapper
  # Versão da gem. O `scripts/release-sdks.sh` do monorepo bumpa a linha abaixo por regex
  # (ancorada no início da linha) e o `bzapper.gemspec` lê daqui — não mude o formato dela.
  VERSION = "0.8.1"
end
