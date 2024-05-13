# db/seeds.rb

# Create 10 developers
10.times do |i|
    User.create!(
      email: "developer#{i + 1}@example.com",
      password: "password",
      name: "Developer #{i + 1}",
      user_type: 'developer'
    )
  end
  
  # Create 10 managers
  10.times do |i|
    User.create!(
      email: "manager#{i + 1}@example.com",
      password: "password",
      name: "Manager #{i + 1}",
      user_type: 'manager'
    )
  end
  
  # Create 10 QAs
  10.times do |i|
    User.create!(
      email: "qa#{i + 1}@example.com",
      password: "password",
      name: "QA #{i + 1}",
      user_type: 'qa'
    )
  end
  