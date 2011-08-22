module Web

  module HTTPResponse

    def cached?
      !!@cached
    end

  end

  module ReadableHTTPResponse

    include HTTPResponse

    def read_body(dest = nil, &block)
      yield @body if block_given?
      @body
    end

  end

end
