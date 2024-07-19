FactoryBot.define do
  factory :bug do
    sequence(:ticket_name) { |n| "Bug #{n}" }
    sequence(:ticket_description) { |n| "Bug description #{n}" }
    title { ticket_name }
    description { ticket_description }
    deadline { "2021-05-18" }
    bug_type { "bug" } 
  end
end