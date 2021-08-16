require "application_system_test_case"

class Audits1984::ListingSessionsTest < ApplicationSystemTestCase
  test "Filter sensitive sessions" do
    visit sessions_path

    assert_content "Sensitive printing"
    assert_content "Arithmetic operations"

    check "Only with sensitive access"
    click_on "Filter"

    assert_content "Sensitive printing"
    assert_no_content "Arithmetic operations"
  end
end
