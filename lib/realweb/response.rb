require 'json'

module RealWeb

  # A class which represents data from a response
  class Response

    attr_reader :code, :headers, :body

    def dump
      { :code => @code, :headers => @headers, :body => @body }.to_json
    end

    def self.load(data)
      data = JSON::parse(data)
      self.new(data['code'], data['body'], data['headers'])
    end

    def initialize(code, body, headers)
      @code = code
      @body = body
      @headers = headers || {}
    end

  end

end
