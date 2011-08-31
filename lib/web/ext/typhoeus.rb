require 'typhoeus'

require File.dirname(__FILE__) + '/../http_response'

module Typhoeus

  class Response

    def cached?
      !!@cached
    end

  end

  class Request

    # A dummy cache timeout so that our cache always
    # gets called
    def cache_timeout
      1
    end

  end

  class Hydra

    # Thank you to the creators of Typhoeus for making this so easy
    # to do.

    def initialize_with_web(options = {})
      initialize_without_web(options)
      # On cache set, record this if we should
      cache_setter do |req|
        web = Web::Faker.new req.method, req.url, req.body, req.headers
        if web.desired?
          res = req.response
          web.record res.code, res.body, res.headers_hash
        end
      end
      # On cache get, reconstruct the response and send it back
      cache_getter do |req|
        web = Web::Faker.new req.method, req.url, req.body, req.headers
        if web.desired? && web_response = web.response_for
          # put the headers back together, since we cache them as a dict
          h_str = web_response.headers ?
            web_response.headers.map { |k, v| "#{k}: #{v}" }.join("\n") : ''
          # and then reconstruct the response
          response = Typhoeus::Response.new({
            :code => web_response.code,
            :headers => h_str,
            :body => web_response.body
          })
          response.instance_variable_set :@cached, true
          response
        end
      end
    end

    alias_method :initialize_without_web, :initialize
    alias_method :initialize, :initialize_with_web

  end

end
