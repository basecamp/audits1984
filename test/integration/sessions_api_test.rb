require "test_helper"

class SessionsApiTest < ActionDispatch::IntegrationTest
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Jorge")
    @token_plaintext = Audits1984::AuditorToken.generate_for(@auditor)
  end

  test "GET /sessions returns JSON list of sessions" do
    get "/sessions",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :success
    assert_equal "application/json", response.media_type

    json = JSON.parse(response.body)
    assert json.key?("sessions")
    assert_kind_of Array, json["sessions"]

    # Verify fixtures are loaded (console1984 fixtures have 2 sessions)
    assert json["sessions"].size >= 1

    session = json["sessions"].first
    assert session.key?("id")
    assert session.key?("user")
    assert session.key?("reason")
    assert session.key?("created_at")
    assert session.key?("sensitive")
    assert session.key?("audit_statuses")
    assert_kind_of Array, session["audit_statuses"]
  end

  test "GET /sessions returns sessions ordered by created_at desc" do
    get "/sessions",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :success
    json = JSON.parse(response.body)

    created_at_values = json["sessions"].map { |s| Time.iso8601(s["created_at"]) }
    assert_equal created_at_values.sort.reverse, created_at_values
  end

  test "GET /sessions with sensitive_only filter returns only sensitive sessions" do
    # The sensitive_printing fixture has a sensitive_access
    get "/sessions?sensitive_only=true",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :success
    json = JSON.parse(response.body)

    # All returned sessions should be sensitive
    json["sessions"].each do |session|
      assert session["sensitive"], "Expected session #{session['id']} to be sensitive"
    end
  end

  test "GET /sessions without auth returns 403 forbidden" do
    ApplicationController.class_eval do
      alias_method :original_find_current_auditor_sessions, :find_current_auditor
      def find_current_auditor
        nil
      end
    end

    get "/sessions",
      headers: { "Accept" => "application/json" }

    assert_response :forbidden

    ApplicationController.class_eval do
      alias_method :find_current_auditor, :original_find_current_auditor_sessions
    end
  end
end
