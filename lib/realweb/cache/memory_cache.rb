module RealWeb

  class MemoryCache

    def initialize
      @hash = {}
    end

    def get(key)
      @hash[key]
    end

    def set(key, value, expires = nil)
      raise 'MemoryCache does not support key expiration' if expires
      @hash[key] = value
    end

  end

end
