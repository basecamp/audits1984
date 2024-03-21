source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in audits1984.gemspec.
gemspec

gem 'sqlite3'
gem 'pg'
gem 'mysql2'

group :development do
  gem 'rubocop-rails-omakase', require: false
end

group :test do
  gem 'minitest'

  gem 'rails'
  gem 'sprockets-rails'
  gem 'puma'

  gem 'capybara'
  gem 'cuprite'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
