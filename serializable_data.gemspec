# -*- encoding: utf-8 -*-
require File.expand_path("../lib/serializable_data/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "serializable_data"
  s.version     = SerializableData::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Evan Petrie"]
  s.email       = ["ejp@yahoo.com"]
  s.homepage    = "http://rubygems.org/gems/serializable_data"
  s.summary     = "Allows arbitrary getter/setters to be set on a class and serialized to the database"
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "serializable_data"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake", "0.8.7"
  s.add_development_dependency "activerecord", ">= 2.3.11"
  s.add_development_dependency "flexmock", "0.8.11"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
