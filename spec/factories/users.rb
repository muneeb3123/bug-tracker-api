FactoryBot.define do
    factory :user do
      transient do
        sequence(:user_email) { |n| "user#{n}@example.com" } 
        sequence(:user_name) { |n| "user#{n}" } 
      end
  
      email { user_email }
      password { "password" }
      name { user_name }
      user_type { "manager" }
    end
  end
  