require File.dirname(__FILE__) + '/realweb/ext/net_http'
require File.dirname(__FILE__) + '/realweb/faker'

module RealWeb

  # The adapters
  autoload :RedisCache, File.dirname(__FILE__) + '/realweb/cache/redis_cache'
  autoload :MemcachedCache, File.dirname(__FILE__) + '/realweb/cache/memcached_cache'

  class << self

    attr_writer :cache

    # register a url to cache
    def register(regex, options = {})
      options[:regex] = regex
      registered << options
    end

    # an array of registrations
    def registered
      @registered ||= []
    end

    # Get the cache we're using
    def cache
      @cache ||= RedisCache.new
    end

  end

end
