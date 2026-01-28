require "test_helper"

class Audits1984::AuditsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Jorge")
    @token_plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    @session = Console1984::Session.first
  end

  test "POST /sessions/:id/audits creates an audit and returns JSON" do
    post "/sessions/#{@session.id}/audits",
      params: { audit: { status: "approved", notes: "Looks good" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :created
    assert_equal "application/json", response.media_type

    json = JSON.parse(response.body)
    assert json.key?("audit")

    audit_json = json["audit"]
    assert audit_json.key?("id")
    assert_equal "approved", audit_json["status"]
    assert_equal "Looks good", audit_json["notes"]
    assert_equal @auditor.id, audit_json["auditor_id"]
    assert_equal @session.id, audit_json["session_id"]
    assert audit_json.key?("created_at")
    assert audit_json.key?("updated_at")
  end

  test "POST /sessions/:id/audits with flagged status" do
    post "/sessions/#{@session.id}/audits",
      params: { audit: { status: "flagged", notes: "Suspicious activity" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "flagged", json["audit"]["status"]
    assert_equal "Suspicious activity", json["audit"]["notes"]
  end

  test "POST /sessions/:id/audits without auth returns 403" do
    ApplicationController.any_instance.stubs(:find_current_auditor).returns(nil)

    post "/sessions/#{@session.id}/audits",
      params: { audit: { status: "approved" } },
      headers: { "Accept" => "application/json" }

    assert_response :forbidden
  end

  test "POST /sessions/:id/audits for non-existent session returns 404" do
    post "/sessions/999999/audits",
      params: { audit: { status: "approved" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Not found", json["error"]
  end

  test "PATCH /sessions/:id/audits/:audit_id updates an audit and returns JSON" do
    audit = Audits1984::Audit.create!(
      session: @session,
      auditor: @auditor,
      status: :pending,
      notes: "Initial notes"
    )

    patch "/sessions/#{@session.id}/audits/#{audit.id}",
      params: { audit: { status: "approved", notes: "Updated notes" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :ok
    assert_equal "application/json", response.media_type

    json = JSON.parse(response.body)
    assert json.key?("audit")

    audit_json = json["audit"]
    assert_equal audit.id, audit_json["id"]
    assert_equal "approved", audit_json["status"]
    assert_equal "Updated notes", audit_json["notes"]
    assert_equal @auditor.id, audit_json["auditor_id"]
    assert_equal @session.id, audit_json["session_id"]

    audit.reload
    assert_equal "approved", audit.status
    assert_equal "Updated notes", audit.notes
  end

  test "PUT /sessions/:id/audits/:audit_id also works for update" do
    audit = Audits1984::Audit.create!(
      session: @session,
      auditor: @auditor,
      status: :pending
    )

    put "/sessions/#{@session.id}/audits/#{audit.id}",
      params: { audit: { status: "flagged" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "flagged", json["audit"]["status"]
  end

  test "PATCH /sessions/:id/audits/:audit_id without auth returns 403" do
    audit = Audits1984::Audit.create!(
      session: @session,
      auditor: @auditor,
      status: :pending
    )

    ApplicationController.any_instance.stubs(:find_current_auditor).returns(nil)

    patch "/sessions/#{@session.id}/audits/#{audit.id}",
      params: { audit: { status: "approved" } },
      headers: { "Accept" => "application/json" }

    assert_response :forbidden
  end

  test "PATCH /sessions/:id/audits/:audit_id for non-existent audit returns 404" do
    patch "/sessions/#{@session.id}/audits/999999",
      params: { audit: { status: "approved" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Not found", json["error"]
  end

  test "PATCH /sessions/:id/audits/:audit_id for non-existent session returns 404" do
    patch "/sessions/999999/audits/999999",
      params: { audit: { status: "approved" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Not found", json["error"]
  end

  test "POST /sessions/:id/audits with invalid status returns 422" do
    post "/sessions/#{@session.id}/audits",
      params: { audit: { status: "invalid", notes: "Test" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["error"].include?("'invalid' is not a valid status")
  end

  test "PATCH /sessions/:id/audits/:audit_id with invalid status returns 422" do
    audit = Audits1984::Audit.create!(
      session: @session,
      auditor: @auditor,
      status: :pending
    )

    patch "/sessions/#{@session.id}/audits/#{audit.id}",
      params: { audit: { status: "invalid" } },
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{@token_plaintext}"
      }

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["error"].include?("'invalid' is not a valid status")
  end
end
