FactoryBot.define do
  factory :project do
    transient do
      sequence(:project_name) { |n| "project#{n}" }
      sequence(:project_description) { |n| "project#{n} description" }
    end
    name { project_name }
    description { project_description }
  end
end