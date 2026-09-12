class User < ApplicationRecord
  belongs_to :company
  has_many :assignments, dependent: :destroy
  has_many :assigned_vulnerabilities, through: :assignments, source: :vulnerability

  has_secure_password
  enum :role, { super_admin: 0, reviewer: 1 }
  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :email, presence: true, uniqueness: { scope: :company_id }
  validates :full_name, presence: true
end
