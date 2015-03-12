$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hn_title_generator/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hn_title_generator"
  s.version     = HNTitleGenerator::VERSION
  s.authors     = ["Montana Low"]
  s.email       = ["support@omniref.com"]
  s.homepage    = "https://www.omniref.com/ruby/gems/hn_title_generator"
  s.summary     = "Generates titles for Hacker News posts."
  s.description = "Uses markov chains generated from all existing Hacker News posts to probabalistically generage titles."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "data/titles.yaml", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
end
