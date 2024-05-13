class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :developer, class_name: 'User', foreign_key: 'developer_id', optional: true
  has_one_attached :screenshot

  validates :title, presence: true, uniqueness: { scope: :project_id, message: "should be unique throughout the project" }
  validates :deadline, presence: true
  validates :bug_type, presence: true, inclusion: { in: %w[feature bug] }
  validates :status, presence: true, inclusion: { in: %w[open started resolved completed] }
  validate :validate_attachment_filetypes, on: :create

  enum bug_type: { feature: 0, bug: 1 }
  enum status: { open: 0, started: 1, resolved: 2, completed: 3 }



  def screenshot_url
    Rails.application.routes.url_helpers.url_for(screenshot) if screenshot.attached?
  end

  private

  def validate_attachment_filetypes
    return unless screenshot.attached?

    if !screenshot.content_type.in?(%w[image/png image/gif])
      errors.add(:screenshot, 'needs to be a GIF or PNG')
    end
  end
end
