require File.dirname(__FILE__) + '/../spec_helper'
require 'redis'

describe RealWeb do

  before :each do 
    Redis.new.flushdb
  end
  
  describe RealWeb::RedisCache do

    it 'should return nil for a missing key' do
      cache = RealWeb::RedisCache.new
      cache.get('hello').should be_nil
    end

    it 'should be able to get and set a value' do
      cache = RealWeb::RedisCache.new
      cache.set('hello', 'world')
      cache.get('hello').should == 'world'
    end

    it 'should be able to set an expires and have it honored' do
      cache = RealWeb::RedisCache.new
      cache.set('hello', 'world', 1)
      cache.get('hello').should == 'world'
      sleep 1.5
      cache.get('hello').should be_nil
    end

  end

end
