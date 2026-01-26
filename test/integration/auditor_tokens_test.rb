require "test_helper"

class AuditorTokensTest < ActionDispatch::IntegrationTest
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Jorge")
  end

  test "show page without token" do
    get "/auditor_token"
    assert_response :success
    assert_select "h1", "API Token"
    assert_select "button", "Generate Token"
  end

  test "create token shows plaintext in response" do
    assert_difference "Audits1984::AuditorToken.count", 1 do
      post "/auditor_token"
    end
    assert_response :success

    # Token plaintext should be visible in the response
    assert_select ".message-body code#token-value" do |elements|
      plaintext = elements.first.text
      assert plaintext.length >= 20

      # Verify we can find the token by this plaintext
      token = Audits1984::AuditorToken.find_by_token(plaintext)
      assert_not_nil token
      assert_equal @auditor.id, token.auditor_id
    end

    # Should show the current token info
    assert_select ".box h2", "Current Token"
    assert_select "button", "Regenerate Token"
    assert_select "button", "Revoke Token"
  end

  test "regenerate token replaces existing" do
    first_plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    first_token = Audits1984::AuditorToken.find_by(auditor: @auditor)

    assert_no_difference "Audits1984::AuditorToken.count" do
      post "/auditor_token"
    end
    assert_response :success

    # Old token should be gone
    assert_nil Audits1984::AuditorToken.find_by(id: first_token.id)
    assert_nil Audits1984::AuditorToken.find_by_token(first_plaintext)

    # New token should exist
    new_token = Audits1984::AuditorToken.find_by(auditor: @auditor)
    assert_not_nil new_token
    assert_not_equal first_token.id, new_token.id
  end

  test "destroy token removes it" do
    Audits1984::AuditorToken.generate_for(@auditor)

    assert_difference "Audits1984::AuditorToken.count", -1 do
      delete "/auditor_token"
    end
    assert_redirected_to "/auditor_token"

    follow_redirect!
    assert_response :success
    assert_select "button", "Generate Token"
  end

  test "show page with existing token" do
    Audits1984::AuditorToken.generate_for(@auditor)

    get "/auditor_token"
    assert_response :success
    assert_select ".box h2", "Current Token"
    assert_select "button", "Regenerate Token"
    assert_select "button", "Revoke Token"

    # Should NOT show the plaintext (it's not accessible after creation)
    assert_select "#token-value", count: 0
  end

  test "show page displays expired tag for expired token" do
    Audits1984::AuditorToken.generate_for(@auditor)
    Audits1984::AuditorToken.find_by(auditor: @auditor).update!(expires_at: 1.hour.ago)

    get "/auditor_token"
    assert_response :success
    assert_select ".tag.is-danger", "Expired"
  end
end
