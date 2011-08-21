require File.dirname(__FILE__) + '/../spec_helper'

describe RealWeb do

  before :each do
    Redis.new.flushdb
  end

  describe 'with 1s expired url' do
    
    before :each do
      RealWeb.register /google\.com/, :expire => 1000
    end

    it 'should expire a key after 1s' do
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should_not be_cached
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should be_cached
      sleep 2
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should_not be_cached
    end

  end

  describe 'with registered url' do

    before :each do
      RealWeb.register /google\.com/
    end

    it 'should get the uncached result the first time' do
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should_not be_cached
    end

    it 'should get the cached result the second time' do
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should be_cached
    end

    it 'should have a cached response with the same code' do
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      code = response.code
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should be_cached
      response.code.should == code
    end

    it 'should have same headers as the original response' do
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      headers = {}
      response.each do |key, value|
        headers[key] = value
      end
      headers.should_not be_empty
      # and the other one
      response = Net::HTTP.get_response URI.parse 'http://google.com'
      response.should be_cached
      headers2 = {}
      response.each do |key, value|
        headers2[key] = value
      end
      # same?
      headers.should == headers2
    end

  end

  it 'should not cache things that are not registered' do
    response = Net::HTTP.get_response URI.parse 'http://google.com'
    response = Net::HTTP.get_response URI.parse 'http://google.com'
    response.should_not be_cached
  end

end
