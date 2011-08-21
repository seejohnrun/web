module Web

  module HTTPResponse

    def read_body(dist = nil, &block)
      yield @body if block_given?
      @body
    end

    def cached?
      !!@cached
    end

  end

end
