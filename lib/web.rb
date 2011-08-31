require File.dirname(__FILE__) + '/web/ext/net_http' if defined?(Net::HTTP)
require File.dirname(__FILE__) + '/web/ext/typhoeus' if defined?(Typhoeus)
require File.dirname(__FILE__) + '/web/faker'

module Web

  # The adapters
  autoload :RedisCache, File.dirname(__FILE__) + '/web/cache/redis_cache'
  autoload :MemcachedCache, File.dirname(__FILE__) + '/web/cache/memcached_cache'
  autoload :MemoryCache, File.dirname(__FILE__) + '/web/cache/memory_cache'

  class << self

    attr_writer :cache

    # register a url to cache
    def register(method, regex, options = {})
      options[:method] = method
      options[:regex] = regex
      registered << options
    end

    def unregister_all
      @registered = []
    end

    # an array of registrations
    def registered
      @registered ||= []
    end

    # Get the cache we're using
    def cache
      @cache ||= MemoryCache.new
    end

  end

end
