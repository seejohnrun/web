require 'redis'

module Web

  # A basic cache interface, implemented with Redis

  class RedisCache

    def initialize(client = nil)
      @redis = client || Redis.new
    end

    def get(key)
      @redis.get key
    end

    def set(key, value, expires = nil)
      @redis.set key, value
      @redis.expire key, expires if expires
    end

  end

end
