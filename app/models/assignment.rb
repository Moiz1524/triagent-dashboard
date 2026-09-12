class Assignment < ApplicationRecord
  belongs_to :vulnerability
  belongs_to :user
  validate :user_belongs_to_same_company

  private
  def user_belongs_to_same_company
    errors.add(:user, "must belong to the vulnerability company") if vulnerability && user && vulnerability.company_id != user.company_id
  end
end
