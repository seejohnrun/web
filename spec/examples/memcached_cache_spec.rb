require File.dirname(__FILE__) + '/../spec_helper'
require 'dalli'

describe Web do

  before :each do 
    Dalli::Client.new.flush
  end
  
  describe Web::MemcachedCache do

    it 'should return nil for a missing key' do
      cache = Web::MemcachedCache.new
      cache.get('hello').should be_nil
    end

    it 'should be able to get and set a value' do
      cache = Web::MemcachedCache.new
      cache.set('hello', 'world')
      cache.get('hello').should == 'world'
    end

    it 'should be available until expiration' do
      cache = Web::MemcachedCache.new
      cache.set('hello', 'world', 1)
      cache.get('hello').should == 'world'
    end

    it 'should be able to set an expires and have it honored' do
      cache = Web::MemcachedCache.new
      cache.set('hello', 'world', 1)
      sleep 2
      cache.get('hello').should be_nil
    end

  end

end
