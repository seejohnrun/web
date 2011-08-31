require 'uri'

require 'net/http'
require 'typhoeus'
require File.dirname(__FILE__) + '/../lib/web'

REQUEST_URL_STRING = 'http://google.com'
REQUEST_URL = URI.parse REQUEST_URL_STRING
