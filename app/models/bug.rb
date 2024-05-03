class Bug < ApplicationRecord

  validates :title, presence: true, uniqueness: { scope: :project_id, message: "should be unique throughout the project" }
  validates :deadline, presence: true
  validates :bug_type, presence: true, inclusion: { in: %w[feature bug] }
  validates :status, presence: true, inclusion: { in: %w[open started resolved completed] }

  belongs_to :project
  belongs_to :user

  enum bug_type: { feature: 0, bug: 1 }
  enum status: { open: 0, started: 1, resolved: 2, completed: 3 }
end
