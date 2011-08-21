# Web

Web is a great way to automatically record HTTP responses in a cache so you don't overwhelm an external service.

``` ruby
Web.register :get, /google\.com/
```

By doing that, any request (via Net/HTTP - more adapters coming soon) is cached (in redis by default) and will return as if it hit the web service directly.

``` ruby
Web.register :any, /google\.com/
Net::HTTP.get_print 'http://google.com' # from source
Net::HTTP.get_print 'http://google.com' # from cache!
```

## Auto-expiry

If the cache class you're using supports expiration (redis does), you can also do

``` ruby
Web.register :get, /google\.com/, :expire => 2
```

To automatically expire requests to `google.com` every 2 seconds

## Different Caches

There are multiple cache classes, and you can add your own.  `RedisCache` caching is the default, but if you want to change it you can do something like:

``` ruby
Web.cache = Web::MemcachedCache.new
```

### Existing Cache Classes

* `MemoryCache` - Caches to memory directly
* `RedisCache` - A cache backed by Redis
* `MemcachedCache` - A cache backed by Memcached via Dalli

## Installation

``` bash
gem install web
```

## TODO

* More library adapters - `typhoeus`, `curb`, `patron`, etc

## Author

John Crepezzi (john.crepezzi@gmail.com)
