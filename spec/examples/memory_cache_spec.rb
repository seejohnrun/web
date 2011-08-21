require File.dirname(__FILE__) + '/../spec_helper'

describe Web do

  describe Web::MemoryCache do

    it 'should return nil for a missing key' do
      cache = Web::MemoryCache.new
      cache.get('hello').should be_nil
    end

    it 'should be able to set and get a key' do
      cache = Web::MemoryCache.new
      cache.set('hello', 'world')
      cache.get('hello').should == 'world'
    end

    it 'should not expire immediately' do
      cache = Web::MemoryCache.new
      cache.set('hello', 'world', 1)
      cache.get('hello').should == 'world'
    end

    it 'should be able to have a key expire' do
      cache = Web::MemoryCache.new
      cache.set('hello', 'world', 1)
      sleep 1.5
      cache.get('hello').should be_nil
    end

  end

end
