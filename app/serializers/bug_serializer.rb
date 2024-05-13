class BugSerializer
  include JSONAPI::Serializer
  attributes :title, :description, :status, :created_at, :updated_at, :id, :deadline, :bug_type, :project_id, :creator_id, :screenshot_url, :developer_id, :screenshot
end
