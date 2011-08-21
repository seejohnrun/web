module Web

  class MemoryCache

    def initialize
      @expirations = {}
      @hash = {}
    end

    def get(key)
      expires = @expirations[key]
      @hash[key] if expires.nil? || Time.now < expires
    end

    def set(key, value, expires = nil)
      @hash[key] = value
      @expirations[key] = Time.now + expires if expires
    end

  end

end
