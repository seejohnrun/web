require File.dirname(__FILE__) + '/lib/web/version'

spec = Gem::Specification.new do |s|
  
  s.name = 'web'
  s.author = 'John Crepezzi'
  s.add_development_dependency('rspec')
  s.description = 'web is a library for caching HTTP responses'
  s.email = 'john.crepezzi@gmail.com'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.homepage = 'http://github.com/seejohnrun/web'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'cache HTTP responses'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = Web::VERSION
  s.rubyforge_project = 'web'

end
