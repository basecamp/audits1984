# Generate sample console1984 sessions for testing audits1984
#
# Usage: bin/rails runner script/generate_sample_sessions.rb
#
user = Console1984::User.find_or_create_by!(username: "developer@example.com")

3.times do |i|
  session = Console1984::Session.create!(
    user: user,
    reason: "Investigating issue ##{100 + i}"
  )
  Console1984::Command.create!(session: session, statements: "User.find(#{i + 1})")
  Console1984::Command.create!(session: session, statements: "puts user.email")
  puts "Created session #{session.id}: #{session.reason}"
end

sensitive_session = Console1984::Session.create!(
  user: user,
  reason: "Emergency production fix"
)
sensitive_access = Console1984::SensitiveAccess.create!(
  session: sensitive_session,
  justification: "Need to update user password"
)
Console1984::Command.create!(
  session: sensitive_session,
  statements: "user.update!(password: new_password)",
  sensitive_access: sensitive_access
)
puts "Created sensitive session #{sensitive_session.id}"

puts "\nTotal sessions: #{Console1984::Session.count}"
