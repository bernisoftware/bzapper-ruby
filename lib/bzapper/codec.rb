# frozen_string_literal: true

module Bzapper
  # Codificação de caminho, query e corpo. Sem estado; nada aqui faz rede.
  # @api private
  module Codec
    module_function

    UNRESERVED = /[^A-Za-z0-9\-._~]/n.freeze

    # Percent-encode de um valor inteiro (tudo fora de `A-Z a-z 0-9 - . _ ~`), em UTF-8.
    def escape(value)
      text = value.to_s
      text = text.encode(::Encoding::UTF_8) unless text.encoding == ::Encoding::BINARY
      text.b.gsub(UNRESERVED) { |byte| format("%%%02X", byte.ord) }.force_encoding(::Encoding::US_ASCII)
    end

    # Percent-encode de UM segmento de caminho (`abc 1` → `abc%201`, `/` → `%2F`). JIDs
    # (`5511999990000@s.whatsapp.net`) passam como vieram, só codificados.
    #
    # Vazio, `"."` e `".."` são recusados antes de qualquer requisição: o cliente HTTP (ou um
    # proxy) resolveria `%2E%2E` como navegação de caminho e chamaria outra rota.
    # @raise [ArgumentError]
    def path_segment(value, name)
      raise ArgumentError, "#{name} é obrigatório." if value.nil? || value.equal?(UNSET)

      text = value.to_s
      raise ArgumentError, "#{name} não pode ser vazio." if text.empty?
      raise ArgumentError, "#{name} não pode ser #{text.inspect}." if [".", ".."].include?(text)

      escape(text)
    end

    # `Time`/`DateTime` → ISO 8601 em UTC com `Z` (microssegundos só quando houver).
    def iso_utc(time)
      time = time.getutc
      text = time.strftime("%Y-%m-%dT%H:%M:%S")
      text += format(".%06d", time.usec) unless time.usec.zero?
      "#{text}Z"
    end

    # Valor de query: booleanos como `true`/`false`, datas em ISO 8601 UTC com `Z`, listas
    # como CSV (`style: form, explode: false` da spec), string passa como veio.
    def query_value(value)
      case value
      when Array then value.map { |item| query_value(item) }.join(",")
      when true then "true"
      when false then "false"
      when Time then iso_utc(value)
      else
        if defined?(::DateTime) && value.is_a?(::DateTime)
          iso_utc(value.to_time)
        elsif defined?(::Date) && value.is_a?(::Date)
          "#{value.strftime('%Y-%m-%d')}T00:00:00Z"
        else
          value.to_s
        end
      end
    end

    # `?a=1&b=2` com os pares informados (`nil` é omitido); `""` se não sobra nenhum.
    def query_string(query)
      return "" if query.nil? || query.empty?

      pairs = query.each_with_object([]) do |(key, value), acc|
        next if value.nil? || value.equal?(UNSET)

        acc << "#{escape(key)}=#{escape(query_value(value))}"
      end
      pairs.empty? ? "" : "?#{pairs.join('&')}"
    end

    # Corpo só com o que o usuário informou: {UNSET} sai; `nil` fica e vira `null`.
    def compact(fields)
      fields.reject { |_key, value| value.equal?(UNSET) }
    end

    # Converte o corpo para tipos JSON: chaves viram string, `UNSET` em Hash some, datas viram
    # ISO 8601 (instantes em UTC com `Z`).
    def jsonable(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, item), out|
          next if item.equal?(UNSET)

          out[key.to_s] = jsonable(item)
        end
      when Array then value.map { |item| jsonable(item) }
      when Time then iso_utc(value)
      when Symbol then value.to_s
      else
        if defined?(::DateTime) && value.is_a?(::DateTime)
          iso_utc(value.to_time)
        elsif defined?(::Date) && value.is_a?(::Date)
          value.strftime("%Y-%m-%d")
        else
          value
        end
      end
    end

    # Texto UTF-8 (bytes inválidos trocados) → `[json_ou_nil, texto, é_json?]`.
    def decode_json(raw)
      text = raw.to_s.dup.force_encoding(::Encoding::UTF_8).scrub
      return [nil, text, false] if text.strip.empty?

      [JSON.parse(text), text, true]
    rescue JSON::ParserError
      [nil, text, false]
    end
  end
end
