require File.dirname(__FILE__) + '/response'

module Web

  # A class for representing one faked response
  class Faker

    attr_reader :cache, :key

    def initialize(method, url, body, headers)
      @key = "#{method}:#{url}"
      @cache = Web.cache
      # keep these around
      @url = url
    end

    # whether or not this is a key we want
    def desired?
      @match = Web.registered.detect do |opt|
        opt[:regex] =~ @url
      end
    end

    # Given a response, marshall down and record in redis
    def record(code, body, headers)
      # save and return the response
      res = Web::Response.new code, body, headers
      # Allow expireation to be set
      expires = @match.has_key?(:expire) ? @match[:expire].to_i : nil
      cache.set(key, res.dump, expires)
      res
    end

    # Get the mashalled form from redis and reconstruct
    # into a Web::Response
    def response_for
      if data = cache.get(key)
        Web::Response.load(data)
      else
        nil
      end
    end

  end

end
