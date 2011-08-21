require 'dalli'

module Web

  # a basic cache interface, implemented with memcached

  class MemcachedCache
  
    def initialize(client = nil)
      @client = client || Dalli::Client.new
    end

    def get(key)
      @client.get(key)
    end

    def set(key, value, expires = nil)
      expires ? @client.set(key, value, expires) : @client.set(key, value)
    end

  end

end
