require File.dirname(__FILE__) + '/../spec_helper'
require 'redis'

describe Web do

  before :each do 
    Redis.new.flushdb
  end
  
  describe Web::RedisCache do

    it 'should return nil for a missing key' do
      cache = Web::RedisCache.new
      cache.get('hello').should be_nil
    end

    it 'should be able to get and set a value' do
      cache = Web::RedisCache.new
      cache.set('hello', 'world')
      cache.get('hello').should == 'world'
    end

    it 'should be able to set an expires and have it honored' do
      cache = Web::RedisCache.new
      cache.set('hello', 'world', 1)
      cache.get('hello').should == 'world'
      sleep 2
      cache.get('hello').should be_nil
    end

  end

end
