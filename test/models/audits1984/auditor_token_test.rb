require "test_helper"

class Audits1984::AuditorTokenTest < ActiveSupport::TestCase
  setup do
    @auditor = Auditor.find_or_create_by!(name: "Test Auditor")
  end

  test "generate_for creates a new token and returns plaintext" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)

    assert_not_nil plaintext
    assert_kind_of String, plaintext
    assert plaintext.length >= 20

    token = Audits1984::AuditorToken.find_by(auditor: @auditor)
    assert_not_nil token
    assert_not_equal plaintext, token.token_digest
    assert token.expires_at > Time.current
  end

  test "generate_for replaces existing token" do
    first_plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    first_token = Audits1984::AuditorToken.find_by(auditor: @auditor)

    second_plaintext = Audits1984::AuditorToken.generate_for(@auditor)
    second_token = Audits1984::AuditorToken.find_by(auditor: @auditor)

    assert_not_equal first_plaintext, second_plaintext
    assert_equal 1, Audits1984::AuditorToken.where(auditor: @auditor).count
    assert_nil Audits1984::AuditorToken.find_by(id: first_token.id)
    assert Audits1984::AuditorToken.find_by(id: second_token.id)
  end

  test "find_by_token returns token for valid plaintext" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)

    found_token = Audits1984::AuditorToken.find_by_token(plaintext)

    assert_not_nil found_token
    assert_equal @auditor.id, found_token.auditor_id
  end

  test "find_by_token returns nil for invalid plaintext" do
    Audits1984::AuditorToken.generate_for(@auditor)

    assert_nil Audits1984::AuditorToken.find_by_token("invalid_token")
  end

  test "find_by_token returns nil for blank plaintext" do
    Audits1984::AuditorToken.generate_for(@auditor)

    assert_nil Audits1984::AuditorToken.find_by_token(nil)
    assert_nil Audits1984::AuditorToken.find_by_token("")
  end

  test "find_by_token returns nil for expired token" do
    plaintext = Audits1984::AuditorToken.generate_for(@auditor)

    assert Audits1984::AuditorToken.find_by_token(plaintext)

    Audits1984::AuditorToken.find_by(auditor: @auditor).update!(expires_at: 1.hour.ago)

    assert_nil Audits1984::AuditorToken.find_by_token(plaintext)
  end

  test "expired? returns true for expired token" do
    Audits1984::AuditorToken.generate_for(@auditor)
    token = Audits1984::AuditorToken.find_by(auditor: @auditor)
    token.update!(expires_at: 1.hour.ago)

    assert token.expired?
  end

  test "expired? returns false for active token" do
    Audits1984::AuditorToken.generate_for(@auditor)
    token = Audits1984::AuditorToken.find_by(auditor: @auditor)

    assert_not token.expired?
  end

  test "token expires after one week by default" do
    freeze_time do
      Audits1984::AuditorToken.generate_for(@auditor)
      token = Audits1984::AuditorToken.find_by(auditor: @auditor)

      assert_equal 1.week.from_now, token.expires_at
    end
  end

  test "active scope excludes expired tokens" do
    Audits1984::AuditorToken.generate_for(@auditor)
    token = Audits1984::AuditorToken.find_by(auditor: @auditor)

    assert_includes Audits1984::AuditorToken.active, token

    token.update!(expires_at: 1.hour.ago)

    assert_not_includes Audits1984::AuditorToken.active, token
  end

  test "token is deleted when auditor is destroyed" do
    auditor = Auditor.create!(name: "Doomed Auditor")
    Audits1984::AuditorToken.generate_for(auditor)
    token_id = Audits1984::AuditorToken.find_by(auditor: auditor).id

    auditor.destroy!

    assert_nil Audits1984::AuditorToken.find_by(id: token_id)
  end
end
