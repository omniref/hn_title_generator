$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "markov_news/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "markov_news"
  s.version     = MarkovNews::VERSION
  s.authors     = ["Montana Low"]
  s.email       = ["support@omniref.com"]
  s.homepage    = "https://www.omniref.com/ruby/gems/markov_news"
  s.summary     = "Hacker news titles generated from markov chains."
  s.description = "Creates blog post titles from markov chains built from all the submissions to hacker news."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "data/titles.yaml", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
end
