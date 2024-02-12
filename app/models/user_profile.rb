class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile

  validates :gov_id, uniqueness: true

  validates :street_address_1, :street_address_2, length: { maximum: 70 }
  validates :first_name, :last_name, :city, :region, :country, :company_name, :email, length: { maximum: 50 }
  validates :gov_id, :postal_code, length: { maximum: 12 }

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:capitalize).join(' ')
  end

  def address
    [street_address_1, street_address_2, city, postal_code, region,
     country].reject(&:blank?).collect(&:titleize).join(', ')
  end

  def address_line1
    [street_address_1].reject(&:blank?).collect(&:titleize).join(', ')
  end

  def address_line2
    [street_address_2].reject(&:blank?).collect(&:titleize).join(', ')
  end

  def address_line_3
    [city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(', ')
  end
end
