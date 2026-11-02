require "test_helper"

class SessionTextTest < ActionDispatch::IntegrationTest
  setup do
    Auditor.find_or_create_by!(name: "Jorge")

    @session = Console1984::Session.create! user: Console1984::User.first,
      reason: %(<img src="x" onerror="alert(1)"> see https://example.com/cards/1?a=1&b=2)
    sensitive_access = @session.sensitive_accesses.create! justification: %(<b onclick="x()">consent</b> https://example.com/conversations/2)
    @session.commands.create! statements: %(puts "<i>#{"hello"}</i>"), sensitive_access: sensitive_access
  end

  test "shows a session's reason as text, with its links" do
    get "/sessions/#{@session.id}"

    assert_response :success
    assert_select "h2.title img", 0
    assert_select "h2.title", text: /<img src="x" onerror="alert\(1\)"> see/
    assert_select "h2.title a[href=?]", "https://example.com/cards/1?a=1&b=2", text: "https://example.com/cards/1?a=1&b=2"
  end

  test "shows a sensitive access's justification as text, with its links" do
    get "/sessions/#{@session.id}"

    assert_response :success
    assert_select ".card p.subtitle b", 0
    assert_select ".card p.subtitle", text: /<b onclick="x\(\)">consent<\/b>/
    assert_select ".card p.subtitle a[href=?]", "https://example.com/conversations/2"
  end

  test "shows executed code as text" do
    get "/sessions/#{@session.id}"

    assert_response :success
    assert_select "pre.highlight i", 0
    assert_select "pre.highlight", text: /<i>/
  end
end
