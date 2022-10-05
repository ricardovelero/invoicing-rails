class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile
  validates :street_address_1, presence: true
  validates :city, presence: true
  validates :region, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
end
