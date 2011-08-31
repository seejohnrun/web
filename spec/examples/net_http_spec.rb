require 'net/http'
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
      response = Net::HTTP.get_response REQUEST_URL
      response.should_not be_cached
      response = Net::HTTP.get_response REQUEST_URL
      response.should be_cached
    end

    it 'should expire a key after 1s' do
      response = Net::HTTP.get_response REQUEST_URL
      response.should_not be_cached
      sleep 2
      response = Net::HTTP.get_response REQUEST_URL
      response.should_not be_cached
    end

  end

  describe 'with registered url' do

    before :each do
      Web.register :get, /google\.com/
    end

    it 'should get the uncached result the first time' do
      response = Net::HTTP.get_response REQUEST_URL
      response.should_not be_cached
    end

    it 'should get the cached result the second time' do
      response = Net::HTTP.get_response REQUEST_URL
      response = Net::HTTP.get_response REQUEST_URL
      response.should be_cached
    end

    it 'should have a cached response with the same code' do
      response = Net::HTTP.get_response REQUEST_URL
      code = response.code
      response = Net::HTTP.get_response REQUEST_URL
      response.should be_cached
      response.code.should == code
    end

    it 'should have same headers as the original response' do
      response = Net::HTTP.get_response REQUEST_URL
      headers = {}
      response.each do |key, value|
        headers[key] = value
      end
      headers.should_not be_empty
      # and the other one
      response = Net::HTTP.get_response REQUEST_URL
      response.should be_cached
      headers2 = {}
      response.each do |key, value|
        headers2[key] = value
      end
      # same?
      headers.should == headers2
    end

    it 'should have the same body as the original' do
      response = Net::HTTP.get_response REQUEST_URL
      orig_body = response.body
      orig_body.strip.should_not == ''
      response = Net::HTTP.get_response REQUEST_URL
      response.body.should == orig_body
    end

    it 'should be able to read the body of an uncached response' do
      lambda do
        response = Net::HTTP.get_response REQUEST_URL
      end.should_not raise_error
    end

    it 'should be able to read the body of an cached response' do
      lambda do
        response = Net::HTTP.get_response REQUEST_URL
        response = Net::HTTP.get_response REQUEST_URL
      end.should_not raise_error
    end

  end

  it 'should be able to read the body of an unregistered response' do
    lambda do
      response = Net::HTTP.get_response REQUEST_URL
    end.should_not raise_error
  end

  it 'should not cache things that are not registered' do
    response = Net::HTTP.get_response REQUEST_URL
    response = Net::HTTP.get_response REQUEST_URL
    response.should_not be_cached
  end

end
