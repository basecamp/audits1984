require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]
end

# Capybara.configure do |config|
#   config.server = :puma, { Silent: true }
#   config.server_host = ENV["CAPYBARA_SERVER_HOST"]
#   config.default_normalize_ws = true
#   config.automatic_label_click = true
#   config.enable_aria_label = true
#   config.enable_aria_role = true
#
#   config.default_max_wait_time = ENV["CI"] ? 30.seconds : 8.seconds
# end
