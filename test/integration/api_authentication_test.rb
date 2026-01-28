require "test_helper"

class ApiAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Jorge")
  end

  test "session auth works for HTML requests" do
    get "/sessions"
    assert_response :success
  end

  test "valid bearer token authenticates HTML requests" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)

    get "/sessions",
      headers: { "Authorization" => "Bearer #{plaintext}" }
    assert_response :success
  end

  test "malformed authorization header falls back to session auth" do
    get "/sessions",
      headers: { "Authorization" => "Basic dXNlcjpwYXNz" }
    assert_response :success
  end

  test "authorization header with only Bearer prefix falls back to session auth" do
    get "/sessions",
      headers: { "Authorization" => "Bearer " }
    assert_response :success
  end
end

class ApiAuthenticationWithoutSessionTest < ActionDispatch::IntegrationTest
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Jorge")
    ApplicationController.any_instance.stubs(:find_current_auditor).returns(nil)
  end

  test "valid bearer token authenticates HTML requests when no session auth" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)

    get "/sessions",
      headers: { "Authorization" => "Bearer #{plaintext}" }
    assert_response :success
  end

  test "invalid bearer token returns 403 for HTML requests when no session auth" do
    get "/sessions",
      headers: { "Authorization" => "Bearer invalid_token" }
    assert_response :forbidden
  end

  test "invalid bearer token returns 403 JSON for JSON requests when no session auth" do
    get "/sessions",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer invalid_token"
      }
    assert_response :forbidden
  end

  test "expired token returns 403 for HTML requests when no session auth" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    Audits1984::AuditorToken.find_by(auditor: @auditor).update!(expires_at: 1.hour.ago)

    get "/sessions",
      headers: { "Authorization" => "Bearer #{plaintext}" }
    assert_response :forbidden
  end

  test "expired token returns 403 JSON for JSON requests when no session auth" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    Audits1984::AuditorToken.find_by(auditor: @auditor).update!(expires_at: 1.hour.ago)

    get "/sessions",
      headers: {
        "Accept" => "application/json",
        "Authorization" => "Bearer #{plaintext}"
      }
    assert_response :forbidden
  end

  test "missing authorization header returns 403 for HTML requests when no session auth" do
    get "/sessions"
    assert_response :forbidden
  end

  test "missing authorization header returns 403 JSON for JSON requests when no session auth" do
    get "/sessions",
      headers: { "Accept" => "application/json" }
    assert_response :forbidden
  end

  test "malformed authorization header returns 403 when no session auth" do
    get "/sessions",
      headers: { "Authorization" => "Basic dXNlcjpwYXNz" }
    assert_response :forbidden
  end
end
