class Project < ApplicationRecord
    has_many :bugs, dependent: :destroy
    has_many :user_projects, dependent: :destroy
    has_many :users, through: :user_projects

    validates :name, presence: true
end
