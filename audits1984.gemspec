require_relative "lib/audits1984/version"

Gem::Specification.new do |spec|
  spec.name        = "audits1984"
  spec.version     = Audits1984::VERSION
  spec.authors     = ["Jorge Manrubia"]
  spec.email       = ["jorge.manrubia@gmail.com"]
  spec.homepage    = "https://github.com/basecamp/audits1984"
  spec.summary     = "A simple auditing tool for console1984"
  spec.description = "Rails engine that implements a simple auditing tool for console1984 sessions"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/basecamp/audits1984"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rouge'
  spec.add_dependency 'turbo-rails'
  spec.add_dependency 'sassc-rails'
  spec.add_dependency 'rinku'
  spec.add_dependency 'console1984'

  spec.add_development_dependency 'rubocop', '>= 1.18.4'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-packaging'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'puma'
end
