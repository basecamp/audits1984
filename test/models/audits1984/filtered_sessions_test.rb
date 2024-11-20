require "test_helper"

class Audits1984::FilteredSessionsTest < ActiveSupport::TestCase
  test "return all sessions ordered by creation date" do
    assert_predicate Console1984::Session, :any?
    assert_equal Console1984::Session.order(created_at: :desc, id: :desc), Audits1984::FilteredSessions.new.all
  end

  test "filter sensitive sessions" do
    assert_filtered_sessions \
      included: console1984_sessions(:sensitive_printing),
      excluded: console1984_sessions(:arithmetic),
      sensitive: true
  end

  test "filter by date" do
    session_from, session_to = console1984_sessions(:arithmetic, :sensitive_printing)
    session_from.update created_at: 1.day.ago
    session_to.update created_at: 1.day.from_now
    from = session_from.created_at
    to = session_to.created_at

    assert_filtered_sessions included: [ session_from, session_to ], from: from, to: to
    assert_filtered_sessions included: [ session_to ], excluded: [ session_from ], from: to
    assert_filtered_sessions included: [ session_from ], excluded: [ session_to ], from: from, to: from
  end

  test "pending_session_after returns the next session considering those are sorted with newest first" do
    first, second = console1984_sessions(:arithmetic, :sensitive_printing).sort_by(&:id).reverse

    filtered_sessions = Audits1984::FilteredSessions.new
    assert_equal second, filtered_sessions.pending_session_after(first)
  end

  test "filter pending sessiosn" do
    audited_session = console1984_sessions(:sensitive_printing)
    auditor = ::Auditor.create!(name: "Jorge")
    audited_session.audits.create!(status: "approved", auditor_id: auditor.id)
    pending_session = console1984_sessions(:arithmetic)

    assert_filtered_sessions \
      included: pending_session,
      excluded: audited_session,
      pending: true
  end

  private
    def assert_filtered_sessions(included: [], excluded: [], sensitive: false, from: nil, to: nil, pending: false)
      assert included.present? || excluded.present?, "Not really testing anything?"

      filtered_sessions = Audits1984::FilteredSessions.new(sensitive_only: sensitive, from_date: from, to_date: to, pending_only: pending)

      Array(included).each do |expected_session|
        assert_includes filtered_sessions.all, expected_session
      end

      Array(excluded).each do |not_expected_session|
        assert_not_includes filtered_sessions.all, not_expected_session
      end
    end
end
