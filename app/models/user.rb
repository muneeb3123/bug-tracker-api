class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  validates :user_type, presence: true, inclusion: { in: %w[developer manager qa] }
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :name, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  def jwt_payload
    super
  end

  enum user_type: [:developer, :manager, :qa]

  scope :developers, -> { where(user_type: 'developer') }
  scope :qas, -> { where(user_type: 'qa') }
  scope :managers, -> { where(user_type: 'manager') }
end
