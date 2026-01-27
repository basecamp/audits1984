require "test_helper"

class Audits1984::ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Jorge")
    @controller = Audits1984::SessionsController.new
  end

  # Although `auditor_from_bearer_token` is a private method, it is part of the engine API that may
  # be called from application controllers that inheritq from `Audits1984::ApplicationController`.
  test "auditor_from_bearer_token with valid token" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)

    @controller.request = ActionDispatch::Request.new("HTTP_AUTHORIZATION" => "Bearer #{plaintext}")

    assert_equal @auditor, @controller.send(:auditor_from_bearer_token)
  end

  test "auditor_from_bearer_token with invalid token" do
    @controller.request = ActionDispatch::Request.new("HTTP_AUTHORIZATION" => "Bearer invalid_token")

    assert_nil @controller.send(:auditor_from_bearer_token)
  end

  test "auditor_from_bearer_token with expired token" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    Audits1984::AuditorToken.find_by(auditor: @auditor).update!(expires_at: 1.hour.ago)

    @controller.request = ActionDispatch::Request.new("HTTP_AUTHORIZATION" => "Bearer #{plaintext}")

    assert_nil @controller.send(:auditor_from_bearer_token)
  end

  test "auditor_from_bearer_token with missing header" do
    @controller.request = ActionDispatch::Request.new({})

    assert_nil @controller.send(:auditor_from_bearer_token)
  end

  test "auditor_from_bearer_token with non-Bearer auth" do
    @controller.request = ActionDispatch::Request.new("HTTP_AUTHORIZATION" => "Basic dXNlcjpwYXNz")

    assert_nil @controller.send(:auditor_from_bearer_token)
  end

  test "auditor_from_bearer_token with empty Bearer token" do
    @controller.request = ActionDispatch::Request.new("HTTP_AUTHORIZATION" => "Bearer ")

    assert_nil @controller.send(:auditor_from_bearer_token)
  end
end
