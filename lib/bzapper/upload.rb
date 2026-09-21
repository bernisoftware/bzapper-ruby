# frozen_string_literal: true

module Bzapper
  # Arquivo de um upload `multipart/form-data` (logo da marca, logo do projeto, mídia de
  # campanha). Montado pela SDK a partir de `file:`, `filename:` e `content_type:`.
  # @api private
  class Upload
    DEFAULT_CONTENT_TYPE = "application/octet-stream"

    attr_reader :field, :data, :filename, :content_type

    # @param field [String] nome do campo do formulário (`file`).
    # @param file [String, IO, Pathname] bytes, um IO (lido inteiro agora) ou o caminho no disco.
    # @param filename [String, nil] padrão: o nome do caminho/IO, senão `"file"`.
    # @param content_type [String, nil] padrão: `application/octet-stream`.
    # @raise [ArgumentError] arquivo ausente ou nome inválido.
    def initialize(field, file, filename: nil, content_type: nil)
      raise ArgumentError, "file é obrigatório (bytes, IO ou Pathname)." if file.nil? || file.equal?(UNSET)

      guessed = nil
      if defined?(::Pathname) && file.is_a?(::Pathname)
        guessed = file.basename.to_s
        @data = File.binread(file.to_s)
      elsif file.respond_to?(:read)
        guessed = File.basename(file.path.to_s) if file.respond_to?(:path) && file.path
        @data = file.read.to_s.b
      elsif file.is_a?(String)
        @data = file.b
      else
        raise TypeError, "file precisa ser String (bytes), IO ou Pathname (recebeu #{file.class})."
      end

      @field = field
      @filename = (filename || guessed).to_s
      @filename = "file" if @filename.empty?
      if @filename.match?(/[\r\n"]/)
        raise ArgumentError, "filename não pode ter aspas nem quebra de linha: #{@filename.inspect}"
      end

      @content_type = (content_type || DEFAULT_CONTENT_TYPE).to_s
      raise ArgumentError, "content_type inválido: #{@content_type.inspect}" if @content_type.match?(/[\r\n]/)
    end

    # Corpo `multipart/form-data` → `[bytes, content_type_do_cabeçalho]`. A fronteira é gerada
    # uma vez por chamada lógica (as novas tentativas reenviam os mesmos bytes).
    def encode
      boundary = "bzapper-#{SecureRandom.hex(16)}"
      body = +"".b
      body << "--#{boundary}\r\n".b
      body << "Content-Disposition: form-data; name=\"#{@field}\"; filename=\"#{@filename}\"\r\n".b
      body << "Content-Type: #{@content_type}\r\n\r\n".b
      body << @data
      body << "\r\n--#{boundary}--\r\n".b
      [body, "multipart/form-data; boundary=#{boundary}"]
    end

    def inspect
      "#<Bzapper::Upload field=#{@field.inspect} filename=#{@filename.inspect} bytes=#{@data.bytesize}>"
    end
  end
end
