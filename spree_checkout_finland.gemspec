# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spree_checkout_finland/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_checkout_finland'
  s.version     = SpreeCheckoutFinland::VERSION
  s.summary     = 'Adds Checkout Finland as a Payment Method to Spree Commerce'
  s.description = s.summary
  s.required_ruby_version = '>= 2.1.0'

  s.author       = 'Rockaberry Oy'
  s.email        = 'admin@rockaberry.fi'
  s.homepage     = 'http://www.rockaberry.fi'
  s.license      = %q{MIT}

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.1.0'
end
