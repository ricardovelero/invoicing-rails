class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:capitalize).join(" ")
  end
end
