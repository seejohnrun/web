require 'net/http'
require 'typhoeus'
require File.dirname(__FILE__) + '/../spec_helper'

describe Web do

  before :each do
    Web.cache = Web::MemoryCache.new
    Web.unregister_all
    Web.register :get, /google\.com/
  end

  it 'should be able to share a cached response from Net::HTTP to Typhoeus' do
    response = Typhoeus::Request.get REQUEST_URL_STRING
    response.should_not be_cached
    response = Net::HTTP.get_response REQUEST_URL
    response.should be_cached 
  end

  it 'should be able to share a cached response from Typhoeus to Net::HTTP' do
    response = Net::HTTP.get_response REQUEST_URL
    response.should_not be_cached
    response = Typhoeus::Request.get REQUEST_URL_STRING
    response.should be_cached
  end

  it 'should share a body, code, and headers' do
    Net::HTTP.get_response REQUEST_URL
    cresponse1 = Net::HTTP.get_response REQUEST_URL
    Typhoeus::Request.get REQUEST_URL_STRING
    cresponse2 = Typhoeus::Request.get REQUEST_URL_STRING
    # body
    cresponse1.body.should == cresponse2.body
    # code
    cresponse1.code.to_i.should == cresponse2.code
    # headers
    net_headers = {}
    cresponse1.each do |key, value|
      net_headers[key.downcase] = value
    end
    t_headers = {}
    cresponse2.headers_hash.each do |key, value|
      t_headers[key.downcase] = value
    end
    t_headers.should == net_headers
  end

end
