require 'net/http'
require 'net/https'
require 'stringio'

require File.dirname(__FILE__) + '/../status_codes'
require File.dirname(__FILE__) + '/../http_response'

module Net

  class BufferedIO

    # Catch the socket
    # This method was largely influenced by FakeWeb
    def initialize_with_web(io, debug_output = nil)
      @read_timeout = 60
      @rbuf = ''
      @debug_output = debug_output
      # If io is a socket, use it directly
      # If io is a string that represents a file path, open the file
      # Otherwise, open a StringIO so we can stream
      @io = case io
      when Socket, OpenSSL::SSL::SSLSocket, IO
        io
      when String
        if !io.include?("\0") && File.exists?(io) && !File.directory?(io)
          File.open(io, 'r')
        else
          StringIO.new(io)
        end
      end
      # make sure we have the stream open
      raise 'Unable to create local socket' unless @io
    end

    alias_method :initialize_without_web, :initialize
    alias_method :initialize, :initialize_with_web

  end

  class HTTP

    class << self

      def socket_type_with_web
        Web::StubSocket
      end

      alias_method :socket_type_without_web, :socket_type
      alias_method :socket_type, :socket_type_with_web

    end

    def request_with_web(request, body = nil, &block)
      connect
      # get a faker
      headers = {}
      request.each do |key, value|
        headers[key] = value
      end
      web = Web::Faker.new request.method.downcase.to_sym, request_uri_as_string(request), body, headers
      if web.desired? && web_response = web.response_for
        # turn the web response into a Net::HTTPResponse
        response = Net::HTTPResponse.send(:response_class, web_response.code.to_s).new('1.0', web_response.code.to_s, HTTP_STATUS_CODES[web_response.code])
        web_response.headers.each do |name, value|
          if value.respond_to?(:each)
            value.each { |val| response.add_field(name, val) }
          else
            response[name] = value
          end
        end
        response.extend Web::ReadableHTTPResponse
        response.instance_variable_set(:@body, web_response.body)
        response.instance_variable_set(:@read, true)
        yield response if block_given?
        # respond cached
        response.instance_variable_set(:@cached, true)
        response
      else
        # get the  response and store it if its desirable
        if web.desired?
          response = request_without_web(request, body)
          headers = {}
          response.each do |key, value|
            headers[key] = value
          end
          response.extend Web::ReadableHTTPResponse
          web.record response.code.to_i, response.body, headers
          yield response if block_given?
          response
        else
          response = request_without_web(request, body, &block)
          response.extend Web::HTTPResponse
          response
        end
      end
    end

    alias_method :request_without_web, :request
    alias_method :request, :request_with_web

    private

    def request_uri_as_string(request)
      protocol = use_ssl? ? 'https' : 'http'
      path = request.path
      path = URI.parse(request.path).request_uri if request.path =~ /^http/
      path = path.chop if path.end_with?('/') # remove trailing slashes in caching layer
      # TODO handle basic auth
      if (use_ssl? && port == 443) || (!use_ssl? && port == 80)
        "#{protocol}://#{address}#{path}"
      else
        "#{protocol}://#{address}:#{port}#{path}"
      end
    end

  end

end

module Web

  module ReadableHTTPResponse

    include HTTPResponse

    def read_body(dest = nil, &block)
      yield @body if block_given?
      @body
    end

  end

end
