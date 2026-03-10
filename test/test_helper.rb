# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"

require "console1984"

ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]

require "rails/test_help"
require "mocha/minitest"

# Load fixtures from console1984 engine (not local fixtures)
console1984_fixtures = Console1984::Engine.root.join("test", "fixtures")

ActiveSupport::TestCase.fixture_paths = [ console1984_fixtures ]
ActiveSupport::TestCase.file_fixture_path = console1984_fixtures.join("files")
ActiveSupport::TestCase.fixtures :all
