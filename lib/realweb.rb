require 'redis'
require 'json'

require File.dirname(__FILE__) + '/realweb/ext/net_http'
require File.dirname(__FILE__) + '/realweb/faker'

module RealWeb

  # Auto-loading
  autoload :Cache, File.dirname(__FILE__) + '/realweb/cache'

  class << self

    # register a url to cache
    def register(regex, options = {})
      options[:regex] = regex
      registered << options
    end

    # an array of registrations
    def registered
      @registered ||= []
    end

  end

end
