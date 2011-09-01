# Web

Web is a great way to automatically record HTTP responses in a cache so you don't overwhelm an external service. You can also share the responses between multiple machines and multiple adapters (like typhoeus and net/http) seamlessly.

``` ruby
Web.register :get, /google\.com/
```

By doing that, any request is cached and will return as if it hit the web service directly. By default, the caching is to memory, but there are also adapters for caching via Memcached, Redis, or a custom adapter. (see below)

``` ruby
Web.register :any, /google\.com/
Net::HTTP.get_print URI.parse 'http://google.com' # from source
Net::HTTP.get_print URI.parse 'http://google.com' # from cache!
Typhoeus::Request.get 'http://google.com' # from cache!
```

## Auto-expiry

You can also do

``` ruby
Web.register :get, /google\.com/, :expire => 2
```

To automatically expire requests to `google.com` every 2 seconds

---

## Different Caches

There are multiple cache classes, and you can add your own.  `MemoryCache` caching is the default, but if you want to change it you can do something like:

``` ruby
Web.cache = Web::MemcachedCache.new
```

### Existing Cache Classes

* `MemoryCache` - Caches to memory directly
* `RedisCache` - A cache backed by Redis
* `MemcachedCache` - A cache backed by Memcached via Dalli

### Custom Cache Classes

Custom caches are expected to respond to `get(key)` and `set(key, value, expiry_s)`. `lib/web/cache/redis_cache.rb` is a great example implementation.

---

### Adapters

There is currently support for the following adapters:

* `typhoeus`
* `net/http`

It's easy to write new adapters, and the typhoeus adapter is a great example.  Give it a read at `lib/web/ext/typhoeus.rb` and contribute one for another library, like `curb` or `patron`.

## Seeing if a response is cached

Response objects from the adapters all have an added method called `cached?` that will return a boolean indicating whether or not the source of the response was the cache.

## Installation

``` bash
gem install web
```

## Author

John Crepezzi (john.crepezzi@gmail.com)
