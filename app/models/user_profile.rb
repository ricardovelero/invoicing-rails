class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile
end
