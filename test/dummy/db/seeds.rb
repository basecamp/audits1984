# Clear existing data to avoid duplication
Console1984::User.destroy_all
Console1984::Session.destroy_all
Console1984::Command.destroy_all
Console1984::SensitiveAccess.destroy_all

# Seed Users
users = [
  { username: "alice_wonder" },
  { username: "bob_builder" },
  { username: "charlie_day" }
].map do |user_attrs|
  Console1984::User.create!(user_attrs)
end

puts "#{Console1984::User.count} users created!"

# Seed Sessions
sessions = users.map do |user|
  Array.new(2) do # Create 2 sessions per user
    Console1984::Session.create!(
      user: user,
      reason: [ "Debugging issue", "Performance testing", "Feature testing" ].sample,
      created_at: rand(1..30).days.ago,
      updated_at: Time.now
    )
  end
end.flatten

puts "#{Console1984::Session.count} sessions created!"

# Seed SensitiveAccess
sensitive_accesses = sessions.map do |session|
  Array.new(2) do # Create 2 sensitive accesses per session
    Console1984::SensitiveAccess.create!(
      session: session,
      justification: [ "Accessing protected data", "Investigating security issues" ].sample,
      created_at: rand(1..30).days.ago,
      updated_at: Time.now
    )
  end
end.flatten

puts "#{Console1984::SensitiveAccess.count} sensitive accesses created!"

# Seed Commands with Ruby statements
commands = sessions.map do |session|
  Array.new(5) do # Create 5 commands per session
    Console1984::Command.create!(
      session: session,
      sensitive_access: [ nil, sensitive_accesses.sample ].sample, # Randomly associate with a sensitive access or not
      statements: [
        "User.find_by(username: 'alice_wonder')",
        "Project.all.map(&:name)",
        "User.last.update!(admin: true)",
        "Order.pending.count",
        "Rails.logger.info 'Debugging session started'"
      ].sample,
      created_at: rand(1..30).days.ago,
      updated_at: Time.now
    )
  end
end.flatten

puts "#{Console1984::Command.count} commands created!"
