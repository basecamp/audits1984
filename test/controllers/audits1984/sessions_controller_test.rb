require "test_helper"

class Audits1984::SessionsControllerTest < ActionDispatch::IntegrationTest
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
    get "/sessions",
      params: { sensitive_only: true },
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

  test "GET /sessions with pending filter returns only sessions with no audits" do
    # Create an audit on one session so we have both pending and reviewed sessions
    session_with_audit = Console1984::Session.first
    Audits1984::Audit.create!(session: session_with_audit, auditor: @auditor, status: :approved)

    get "/sessions",
      params: { pending_only: true },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :success
    json = JSON.parse(response.body)

    # All returned sessions should have no audits (pending)
    json["sessions"].each do |session|
      assert_empty session["audit_statuses"], "Expected session #{session['id']} to have no audits"
    end

    # The session with an audit should not be in the results
    returned_ids = json["sessions"].map { |s| s["id"] }
    assert_not_includes returned_ids, session_with_audit.id
  end

  test "GET /sessions without auth returns 403 forbidden" do
    ApplicationController.any_instance.stubs(:find_current_auditor).returns(nil)

    get "/sessions",
      headers: { "Accept" => "application/json" }

    assert_response :forbidden
  end

  test "GET /sessions/:id returns JSON session with command_batches and audits" do
    session = Console1984::Session.first

    get "/sessions/#{session.id}",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :success
    assert_equal "application/json", response.media_type

    json = JSON.parse(response.body)
    assert json.key?("session")

    session_json = json["session"]
    assert_equal session.id, session_json["id"]
    assert session_json.key?("user")
    assert session_json.key?("reason")
    assert session_json.key?("created_at")
    assert session_json.key?("sensitive")

    # Verify command_batches structure (commands grouped by sensitive access)
    assert session_json.key?("command_batches")
    assert_kind_of Array, session_json["command_batches"]

    if session_json["command_batches"].any?
      batch = session_json["command_batches"].first
      assert batch.key?("sensitive")
      assert batch.key?("justification")
      assert batch.key?("commands")
      assert_kind_of Array, batch["commands"]
    end

    # Verify audits structure
    assert session_json.key?("audits")
    assert_kind_of Array, session_json["audits"]
  end

  test "GET /sessions/:id includes audit details when audits exist" do
    session = Console1984::Session.first
    audit = Audits1984::Audit.create!(
      session: session,
      auditor: @auditor,
      status: :approved,
      notes: "Looks good"
    )

    get "/sessions/#{session.id}",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :success
    json = JSON.parse(response.body)

    audits = json["session"]["audits"]
    assert audits.any?, "Expected at least one audit"

    audit_json = audits.find { |a| a["id"] == audit.id }
    assert_not_nil audit_json
    assert_equal "approved", audit_json["status"]
    assert_equal "Looks good", audit_json["notes"]
    assert_equal @auditor.id, audit_json["auditor_id"]
    assert audit_json.key?("created_at")
  end

  test "GET /sessions/:id without auth returns 403 forbidden" do
    session = Console1984::Session.first

    ApplicationController.any_instance.stubs(:find_current_auditor).returns(nil)

    get "/sessions/#{session.id}",
      headers: { "Accept" => "application/json" }

    assert_response :forbidden
  end

  test "GET /sessions/:id for non-existent session returns 404" do
    get "/sessions/999999",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Not found", json["error"]
  end
end
