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

    it 'should raise an error when trying to use expires' do
      cache = Web::MemoryCache.new
      lambda do
        cache.set('hello', 'world', :expire => 2)
      end.should raise_error(RuntimeError)
    end

  end

end
