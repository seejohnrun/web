require 'typhoeus'
require File.dirname(__FILE__) + '/../spec_helper'

describe Web do

  before :each do
    Web.cache = Web::MemoryCache.new
    Web.unregister_all
  end

  describe 'with 1s expired url' do

    before :each do
      Web.register :get, /google\.com/, :expire => 1
    end

    it 'should not expire immediately' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should_not be_cached
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should be_cached
    end

    it 'should expire a key after 1s' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should_not be_cached
      sleep 2
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should_not be_cached
    end

  end

  describe 'with regsitered url' do
    
    before :each do
      Web.register :get, /google\.com/
    end

    it 'should get the uncached result the first time' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should_not be_cached
    end

    it 'should get the cached result the second time' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should be_cached
    end

    it 'should have a cached response with the same code' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      code = response.code
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should be_cached
      response.code.should == code
    end

    it 'should have the same body as the original' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      orig_body = response.body
      orig_body.strip.should_not == ''
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.body.should == orig_body
    end

    it 'should have same headers as the original response' do
      response = Typhoeus::Request.get REQUEST_URL_STRING
      headers = {}
      response.headers_hash.each do |key, value|
        headers[key] = value
      end
      headers.should_not be_empty
      # and the other one
      response = Typhoeus::Request.get REQUEST_URL_STRING
      response.should be_cached
      headers2 = {}
      response.headers_hash.each do |key, value|
        headers2[key] = value
      end
      # same?
      headers.should == headers2
    end

  end

  it 'should not cache things that are not registered' do
    response = Typhoeus::Request.get REQUEST_URL_STRING
    response = Typhoeus::Request.get REQUEST_URL_STRING
    response.should_not be_cached
  end

end
