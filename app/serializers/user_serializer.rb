class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :created_at, :name, :user_type
end
