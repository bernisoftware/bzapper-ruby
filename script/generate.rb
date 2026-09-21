# frozen_string_literal: true

# Gera os métodos da SDK Ruby a partir de `packages/sdk/openapi.yaml` (só no monorepo).
#
#   ruby script/generate.rb          # (re)escreve lib/bzapper/resources/*.rb e test/support/ops_table.rb
#   ruby script/generate.rb --check  # falha se algo gerado estiver desatualizado
#
# Regra (BRIEF §6): toda operação da spec vira um método, exceto `sdk_excluded_ops` de
# `test/fixtures/conformance/cases.json`. Nome = `operationId` em snake_case; o recurso é a
# 1ª tag da operação (`client.messages.send_text`). Rotas `/partner/*` vão para o
# `Bzapper::PartnerClient`.
#
# Assinatura gerada: parâmetros de caminho posicionais (na ordem do caminho); query e corpo
# como keyword args — obrigatórios sem padrão; opcionais de query com `nil` (omitido) e de
# corpo com `Bzapper::UNSET` (não enviado; `nil` explícito vai como `null`). Toda chamada
# aceita `timeout:`; escritas aceitam `idempotency_key:`. Upload (multipart) recebe `file:`
# (bytes, IO ou Pathname) + `filename:` + `content_type:`.
#
# Só stdlib (psych + json). Saída determinística.

require "json"
require "psych"

ROOT = File.expand_path("..", __dir__)
SPEC = File.expand_path("../../packages/sdk/openapi.yaml", ROOT)
CASES = File.join(ROOT, "test", "fixtures", "conformance", "cases.json")
METHODS = %w[get post put patch delete].freeze
WRITES = %w[post put patch delete].freeze
RESERVED = %w[
  BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in
  module next nil not or redo rescue retry return self super then true undef unless until when
  while yield __FILE__ __LINE__ __ENCODING__
].freeze
# Nomes que a SDK usa como opção por chamada — um campo da spec com esse nome colidiria.
OPTION_NAMES = %w[timeout idempotency_key file filename content_type].freeze

TAG_DOCS = {
  "accounts" => "Conta, perfil, chaves de API, marca, projetos e usuários",
  "advanced" => "Recursos avançados: editar/apagar/encaminhar, perfil, privacidade, chats, etiquetas, bloqueio e chamadas",
  "advisories" => "Avisos \"atualize sua integração\"",
  "billing" => "Cobrança: plano, assinatura, add-ons, faturas e preços",
  "campaigns" => "Campanhas: estimativa, destinatários, simulação e controle",
  "connect" => "bZapper Connect do lado do CLIENTE: apps parceiros conectados à conta",
  "contacts" => "Contatos (CRM), tags, grupos de contatos, opt-in/out, supressões e checagem",
  "conversations" => "Conversas (inbox) e histórico",
  "groups" => "Grupos do WhatsApp: info, participantes, convite, prévia e pedidos de entrada",
  "instances" => "Números (instâncias): conexão, QR, sessão, proxy, filtros de entrada e conta oficial",
  "messages" => "Envio de mensagens (todos os tipos, OTP), presença e confirmação de leitura",
  "pools" => "Pools de números (rotação)",
  "scheduling" => "Envios agendados",
  "system" => "Saúde e meta",
  "usage" => "Uso medido (consumo)",
  "webhooks" => "Webhooks de eventos (gestão, teste, entregas)"
}.freeze

# ── YAML com booleanos só `true`/`false` (em YAML 1.1 `on` vira booleano — e `on` é campo) ──
module SpecLoader
  module_function

  def scalar(node)
    value = node.value
    return value if node.quoted || node.tag

    case value
    when "true", "True", "TRUE" then true
    when "false", "False", "FALSE" then false
    when "", "~", "null", "Null", "NULL" then nil
    when /\A[-+]?\d+\z/ then value.to_i
    when /\A[-+]?(\d+\.\d*|\.\d+|\d+)([eE][-+]?\d+)?\z/ then value.to_f
    else value
    end
  end

  def conv(node)
    case node
    when Psych::Nodes::Document then conv(node.root)
    when Psych::Nodes::Mapping then node.children.each_slice(2).to_h { |k, v| [k.value, conv(v)] }
    when Psych::Nodes::Sequence then node.children.map { |child| conv(child) }
    when Psych::Nodes::Scalar then scalar(node)
    else raise "nó YAML não suportado: #{node.class}"
    end
  end

  def load(path)
    conv(Psych.parse(File.read(path, encoding: "UTF-8")))
  end
end

class Generator
  def initialize
    @spec = SpecLoader.load(SPEC)
    cases = JSON.parse(File.read(CASES, encoding: "UTF-8"))
    @excluded = cases.fetch("sdk_excluded_ops")
    @case_ops = cases.fetch("ops")
  end

  def resolve(node)
    guard = 0
    while node.is_a?(Hash) && node.key?("$ref")
      node = node["$ref"].delete_prefix("#/").split("/").reduce(@spec) { |cur, part| cur.fetch(part) }
      raise "$ref em ciclo" if (guard += 1) > 20
    end
    node
  end

  def merged(schema)
    schema = resolve(schema || {})
    if schema["allOf"]
      out = { "type" => "object", "properties" => {}, "required" => [] }
      schema["allOf"].each do |part|
        m = merged(part)
        out["properties"].merge!(m["properties"] || {})
        out["required"] += m["required"] || []
      end
      return out
    end
    %w[oneOf anyOf].each { |key| return merged(schema[key].first) if schema[key] }
    schema
  end

  def snake(name)
    name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  end

  def camel(name)
    name.split(/[_-]/).map(&:capitalize).join
  end

  def ruby_type(schema)
    schema = merged(schema)
    type = schema["type"]
    type = (type - ["null"]).first if type.is_a?(Array)
    case type
    when "string"
      %w[date-time date].include?(schema["format"]) ? "Time, String" : "String"
    when "integer" then "Integer"
    when "number" then "Numeric"
    when "boolean" then "Boolean"
    when "array" then "Array<#{ruby_type(schema['items'] || {})}>"
    else "Hash"
    end
  end

  def clean(text)
    text.to_s.gsub(/\s+/, " ").strip
  end

  def wrap(text, width, prefix)
    words = clean(text).split(" ")
    lines = []
    line = +""
    words.each do |word|
      if !line.empty? && line.length + 1 + word.length > width
        lines << line
        line = +""
      end
      line << " " unless line.empty?
      line << word
    end
    lines << line unless line.empty?
    lines.map { |l| "#{prefix}#{l}".rstrip }
  end

  def check_name!(name, oid)
    raise "#{oid}: parâmetro #{name.inspect} não é identificador Ruby" unless name.match?(/\A[a-z_][a-z0-9_]*\z/)
    raise "#{oid}: parâmetro #{name.inspect} é palavra reservada" if RESERVED.include?(name)
    raise "#{oid}: parâmetro #{name.inspect} colide com opção da SDK" if OPTION_NAMES.include?(name)
  end

  # Todas as operações da SDK: [{oid:, method:, path:, tag:, ...}]
  def operations
    @operations ||= begin
      list = []
      @spec.fetch("paths").each do |path, item|
        METHODS.each do |verb|
          op = item[verb] or next
          oid = op.fetch("operationId")
          next if @excluded.include?(oid)

          list << build_op(path, verb, item, op)
        end
      end
      missing = @case_ops - list.map { |o| o[:oid] }
      extra = list.map { |o| o[:oid] } - @case_ops
      raise "ops dos casos sem operação na spec: #{missing}" unless missing.empty?
      raise "ops da spec fora dos casos (rode clients/conformance/generate.py): #{extra}" unless extra.empty?

      list
    end
  end

  def build_op(path, verb, item, op)
    oid = op["operationId"]
    params = ((item["parameters"] || []) + (op["parameters"] || [])).map { |p| resolve(p) }
    path_names = path.scan(/\{([^}]+)\}/).flatten
    path_params = path_names.map do |name|
      p = params.find { |x| x["in"] == "path" && x["name"] == name } || { "name" => name }
      check_name!(name, oid)
      { name: name, doc: clean(p["description"]), type: "String" }
    end
    query = params.select { |p| p["in"] == "query" }.map do |p|
      check_name!(p["name"], oid)
      schema = merged(p["schema"] || { "type" => "string" })
      { name: p["name"], required: p["required"] == true, doc: clean(p["description"]),
        type: ruby_type(schema), array: schema["type"] == "array" }
    end

    rb = resolve(op["requestBody"] || {})
    content = rb["content"] || {}
    body = []
    multipart = false
    if content["application/json"]
      schema = merged(content["application/json"]["schema"])
      raise "#{oid}: corpo JSON que não é objeto" unless schema["type"] == "object" || schema["properties"]

      required = schema["required"] || []
      (schema["properties"] || {}).each do |name, prop|
        prop_m = merged(prop)
        next if prop_m["readOnly"]

        check_name!(name, oid)
        body << { name: name, required: required.include?(name), type: ruby_type(prop),
                  doc: clean(prop_m["description"] || resolve(prop)["description"]) }
      end
    elsif content["multipart/form-data"]
      multipart = true
      schema = merged(content["multipart/form-data"]["schema"])
      extra = (schema["properties"] || {}).reject { |_n, prop| merged(prop)["format"] == "binary" }
      raise "#{oid}: campos multipart além do arquivo não suportados: #{extra.keys}" unless extra.empty?

      file_field = (schema["properties"] || {}).find { |_n, prop| merged(prop)["format"] == "binary" }&.first
      raise "#{oid}: multipart sem campo binário" unless file_field
    elsif !content.empty?
      raise "#{oid}: content-type de corpo não suportado: #{content.keys}"
    end
    names = path_params.map { |x| x[:name] } + query.map { |x| x[:name] } + body.map { |x| x[:name] }
    raise "#{oid}: nomes repetidos entre caminho/query/corpo: #{names}" unless names.uniq.size == names.size

    {
      oid: oid, name: snake(oid), verb: verb.upcase, path: path, tag: (op["tags"] || ["system"]).first,
      summary: clean(op["summary"]), description: op["description"], path_params: path_params,
      query: query, body: body, has_json_body: !content["application/json"].nil?,
      multipart: multipart, file_field: multipart ? file_field : nil,
      partner: path.start_with?("/partner/")
    }
  end

  def signature(op)
    parts = op[:path_params].map { |p| p[:name] }
    fields = op[:query] + op[:body]
    fields.select { |f| f[:required] }.each { |f| parts << "#{f[:name]}:" }
    parts.concat(["file:", "filename: nil", "content_type: nil"]) if op[:multipart]
    op[:query].reject { |f| f[:required] }.each { |f| parts << "#{f[:name]}: nil" }
    op[:body].reject { |f| f[:required] }.each { |f| parts << "#{f[:name]}: UNSET" }
    parts << "idempotency_key: nil" if WRITES.include?(op[:verb].downcase)
    parts << "timeout: nil"
    parts
  end

  def method_source(op, indent)
    pad = " " * indent
    out = []
    out.concat(wrap("#{op[:summary].sub(/[.\s]+\z/, '')}. `#{op[:verb]} #{op[:path]}`", 100 - indent, "#{pad}# "))
    if op[:description] && !clean(op[:description]).empty?
      out << "#{pad}#"
      out.concat(wrap(op[:description], 100 - indent, "#{pad}# "))
    end
    out << "#{pad}#"
    op[:path_params].each do |p|
      out.concat(wrap("@param #{p[:name]} [String] #{p[:doc].empty? ? 'parâmetro de caminho' : p[:doc]}",
                      100 - indent, "#{pad}# ").each_with_index.map { |l, i| i.zero? ? l : l.sub("# ", "#   ") })
    end
    if op[:multipart]
      out << "#{pad}# @param file [String, IO, Pathname] conteúdo do arquivo (bytes), um IO ou o caminho no disco."
      out << "#{pad}# @param filename [String, nil] nome do arquivo (padrão: o do caminho, senão \"file\")."
      out << "#{pad}# @param content_type [String, nil] tipo MIME (padrão: application/octet-stream)."
    end
    (op[:query] + op[:body]).each do |f|
      type = f[:required] ? f[:type] : "#{f[:type]}, nil"
      doc = f[:doc].empty? ? "" : " #{f[:doc]}"
      where = op[:query].include?(f) ? "(query)" : "(corpo)"
      lines = wrap("@param #{f[:name]} [#{type}] #{where}#{doc}", 100 - indent, "#{pad}# ")
      out.concat(lines.each_with_index.map { |l, i| i.zero? ? l : l.sub("# ", "#   ") })
    end
    out << "#{pad}# @param idempotency_key [String, nil] chave de idempotência (senão a SDK gera uma)." if WRITES.include?(op[:verb].downcase)
    out << "#{pad}# @param timeout [Numeric, nil] segundos por tentativa (padrão: o do cliente)."
    out << "#{pad}# @return [Hash, Array, nil] o JSON da resposta, inteiro (nil em 204)."
    out << "#{pad}# @raise [Bzapper::Error] resposta fora de 2xx ou falha de rede."
    unless op[:path_params].empty?
      out << "#{pad}# @raise [ArgumentError] parâmetro de caminho vazio, \".\" ou \"..\"."
    end

    sig = signature(op)
    head = "#{pad}def #{op[:name]}("
    line = head + sig.join(", ") + ")"
    if line.length <= 100
      out << line
    else
      cont = " " * head.length
      rows = []
      current = +""
      sig.each do |part|
        candidate = current.empty? ? part : "#{current}, #{part}"
        if (rows.empty? ? head.length : cont.length) + candidate.length + 2 > 100 && !current.empty?
          rows << current
          current = +part
        else
          current = +candidate
        end
      end
      rows << current
      rows.each_with_index do |row, i|
        prefix = i.zero? ? head : cont
        suffix = i == rows.size - 1 ? ")" : ","
        out << "#{prefix}#{row}#{suffix}"
      end
    end

    body_pad = " " * (indent + 2)
    path_expr = op[:path].gsub(/\{([^}]+)\}/) { "\#{segment(#{Regexp.last_match(1)}, \"#{Regexp.last_match(1)}\")}" }
    args = ["\"#{op[:verb]}\"", "\"#{path_expr}\""]
    unless op[:query].empty?
      pairs = op[:query].map { |f| "\"#{f[:name]}\" => #{f[:name]}" }
      out << "#{body_pad}query = {"
      pairs.each_with_index { |pr, i| out << "#{body_pad}  #{pr}#{i == pairs.size - 1 ? '' : ','}" }
      out << "#{body_pad}}"
      args << "query: query"
    end
    if op[:has_json_body]
      if op[:body].empty?
        args << "body: {}"
      else
        pairs = op[:body].map { |f| "\"#{f[:name]}\" => #{f[:name]}" }
        out << "#{body_pad}payload = compact("
        pairs.each_with_index { |pr, i| out << "#{body_pad}  #{pr}#{i == pairs.size - 1 ? '' : ','}" }
        out << "#{body_pad})"
        args << "body: payload"
      end
    end
    if op[:multipart]
      args << "multipart: upload(\"#{op[:file_field]}\", file, filename, content_type)"
    end
    args << "idempotency_key: idempotency_key" if WRITES.include?(op[:verb].downcase)
    args << "timeout: timeout"
    call = "#{body_pad}request(#{args.join(', ')})"
    if call.length > 100
      out << "#{body_pad}request(#{args.first},"
      rest = args[1..]
      rest.each_with_index do |a, i|
        out << "#{body_pad}        #{a}#{i == rest.size - 1 ? ')' : ','}"
      end
    else
      out << call
    end
    out << "#{pad}end"
    out.join("\n")
  end

  HEADER = "# frozen_string_literal: true\n\n# GERADO por script/generate.rb a partir de packages/sdk/openapi.yaml — não edite à mão.\n"

  def resource_file(tag, ops)
    klass = camel(tag)
    body = ops.map { |op| method_source(op, 6) }.join("\n\n")
    <<~RUBY
      #{HEADER}
      module Bzapper
        module Resources
          # #{TAG_DOCS.fetch(tag)} — `client.#{tag}`.
          class #{klass} < Base
      #{body}
          end
        end
      end
    RUBY
  end

  def partner_file(ops)
    body = ops.map { |op| method_source(op, 6) }.join("\n\n")
    <<~RUBY
      #{HEADER}
      module Bzapper
        module Resources
          # Operações do bZapper Connect do lado do PARCEIRO (`/partner/*`) — métodos do
          # {Bzapper::PartnerClient}.
          module PartnerOperations
      #{body}
          end
        end
      end
    RUBY
  end

  def index_file(groups)
    requires = groups.keys.map { |tag| "require_relative \"resources/#{tag}\"" }
    readers = groups.keys.map do |tag|
      "    # @return [Resources::#{camel(tag)}] #{TAG_DOCS.fetch(tag)}.\n    attr_reader :#{tag}"
    end
    inits = groups.keys.map { |tag| "      @#{tag} = Resources::#{camel(tag)}.new(transport)" }
    <<~RUBY
      #{HEADER}
      require_relative "resources/base"
      #{requires.join("\n")}
      require_relative "resources/partner"

      module Bzapper
        # Os recursos do {Client} (um por tag da spec). Incluído no {Client}.
        # @api private
        module ResourceAccessors
      #{readers.join("\n\n")}

          # Nomes dos recursos, na ordem da spec.
          RESOURCES = %i[#{groups.keys.join(' ')}].freeze

          private

          def build_resources(transport)
      #{inits.join("\n")}
          end
        end
      end
    RUBY
  end

  def ops_table(client_groups, partner_ops)
    rows = []
    client_groups.each do |tag, ops|
      ops.each { |op| rows << [op[:oid], "->(c, _p) { c.#{tag}.method(:#{op[:name]}) }"] }
    end
    partner_ops.each { |op| rows << [op[:oid], "->(_c, p) { p.method(:#{op[:name]}) }"] }
    rows.sort_by!(&:first)
    lines = rows.map { |oid, lam| "    #{oid.inspect} => #{lam}," }
    lines[-1] = lines[-1].chomp(",")
    <<~RUBY
      #{HEADER}
      # Tabela op (operationId dos casos) → método da SDK. Recebe o `Bzapper::Client` e o
      # `Bzapper::PartnerClient` (mesma chave e URL). Op de `cases.json` sem linha aqui FALHA a
      # suíte — é assim que endpoint novo sem método quebra o build.
      module Conformance
        OPS = {
      #{lines.join("\n")}
        }.freeze
      end
    RUBY
  end

  def files
    ops = operations
    partner_ops = ops.select { |o| o[:partner] }
    client_ops = ops.reject { |o| o[:partner] }
    groups = client_ops.group_by { |o| o[:tag] }
    unknown = groups.keys - TAG_DOCS.keys
    raise "tag sem doc em TAG_DOCS: #{unknown}" unless unknown.empty?

    out = {}
    groups.each { |tag, list| out["lib/bzapper/resources/#{tag}.rb"] = resource_file(tag, list) }
    out["lib/bzapper/resources/partner.rb"] = partner_file(partner_ops)
    out["lib/bzapper/resources.rb"] = index_file(groups)
    out["test/support/ops_table.rb"] = ops_table(groups, partner_ops)
    out
  end
end

files = Generator.new.files
if ARGV.include?("--check")
  stale = files.reject { |rel, text| File.file?(File.join(ROOT, rel)) && File.read(File.join(ROOT, rel), encoding: "UTF-8") == text }
  abort("desatualizado — rode `ruby script/generate.rb`:\n  #{stale.keys.join("\n  ")}") unless stale.empty?
  puts "ok: #{files.size} arquivos em dia"
else
  files.each do |rel, text|
    path = File.join(ROOT, rel)
    File.write(path, text, encoding: "UTF-8")
  end
  puts "#{files.size} arquivos escritos"
end
