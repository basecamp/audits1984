require "application_system_test_case"

class Audits1984::AuditSessionsTest < ApplicationSystemTestCase
  setup do
    visit sessions_path
  end

  test "Audit a console session" do
    assert_session_entry "Arithmetic operations", status: "Pending"

    click_on "Arithmetic operations"
    click_on "Approve"

    visit sessions_path
    assert_session_entry "Arithmetic operations", status: "Approved"
  end

  test "Auditing several console sessions in a row" do
    assert_session_entry "Arithmetic operations", status: "Pending"
    assert_session_entry "Sensitive printing", status: "Pending"

    click_on "Sensitive printing"
    click_on "Approve"
    click_on "Approve"

    assert_session_entry "Arithmetic operations", status: "Approved"
    assert_session_entry "Sensitive printing", status: "Approved"
  end

  private
    def assert_session_entry(reason, status:)
      session_row = all(".sessions .session").find { |row| row.find(".session__reason").text =~ /#{reason}/ }
      assert session_row.find(".session__status").text =~ /#{status}/i
    end
end
