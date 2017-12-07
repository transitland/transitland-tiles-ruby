# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = 'tile_utils'
  gem.version = 0.1
  gem.date    = Date.today.to_s

  gem.summary = 'Transitland Tiles: Ruby'
  gem.description = 'TBD'

  gem.authors     = ['irees']
  gem.email       = ['ian@mapzen.com']
  gem.homepage    = 'https://github.com/transitland/transitland-tiles-ruby'

  gem.required_ruby_version = '>= 2.0'

  gem.add_dependency 'rake'
  gem.add_dependency 'google-protobuf'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'pry'

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.require_paths = ['lib']
end
