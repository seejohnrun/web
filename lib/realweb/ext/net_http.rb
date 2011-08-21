require 'net/http'
require 'net/https'
require 'stringio'

require File.dirname(__FILE__) + '/../status_codes'

module RealWeb

  module FakeHTTPResponse

    def read_body(dist = nil, &block)
      yield @body if block_given?
      @body
    end

    def cached?
      !!@cached
    end

  end

end

module Net

  class BufferedIO

    # Catch the socket
    def initialize_with_realweb(io, debug_output = nil)
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

    alias_method :initialize_without_realweb, :initialize
    alias_method :initialize, :initialize_with_realweb

  end

  class HTTP

    class << self

      def socket_type_with_realweb
        RealWeb::StubSocket
      end

      alias_method :socket_type_without_realweb, :socket_type
      alias_method :socket_type, :socket_type_with_realweb

    end

    def request_with_realweb(request, body = nil, &block)
      connect
      # get a faker
      headers = {}
      request.each do |key, value|
        headers[key] = value
      end
      realweb = RealWeb::Faker.new request.method.downcase.to_sym, request_uri_as_string(request), body, headers
      if realweb.desired? && realweb_response = realweb.response_for
        # turn the realweb response into a Net::HTTPResponse
        response = Net::HTTPResponse.send(:response_class, realweb_response.code.to_s).new('1.0', realweb_response.code.to_s, HTTP_STATUS_CODES[realweb_response.code])
        realweb_response.headers.each do |name, value|
          if value.respond_to?(:each)
            value.each { |val| response.add_field(name, val) }
          else
            response[name] = value
          end
        end
        response.extend RealWeb::FakeHTTPResponse
        response.instance_variable_set(:@body, realweb_response.body)
        response.instance_variable_set(:@read, true)
        yield response if block_given?
        # respond cached
        response.instance_variable_set(:@cached, true)
        response
      else
        # get the real response and store it if its desirable
        if realweb.desired?
          response = request_without_realweb(request, body)
          headers = {}
          response.each do |key, value|
            headers[key] = value
          end
          response.extend RealWeb::FakeHTTPResponse
          realweb.record response.code.to_i, response.body, headers
          yield response if block_given?
          response
        else
          response = request_without_realweb(request, body, &block)
          response.extend RealWeb::FakeHTTPResponse
          response
        end
      end
    end

    alias_method :request_without_realweb, :request
    alias_method :request, :request_with_realweb

    private

    def request_uri_as_string(request)
      protocol = use_ssl? ? 'https' : 'http'
      path = request.path
      path = URI.parse(request.path).request_uri if request.path =~ /^http/
      # TODO handle basic auth
      "#{protocol}://#{address}:#{port}#{path}"
    end

  end

end
