module RealWeb

  # A basic cache interface, implemented with Redis by default

  class Cache

    def initialize
      @redis = Redis.new
    end

    def get(key)
      @redis.get(key)
    end

    def set(key, value, expires = nil)
      @redis.set(key, value)
      @redis.expire key, expires / 1000 if expires
    end

  end

end
