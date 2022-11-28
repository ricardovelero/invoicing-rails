class UserProfile < ApplicationRecord
  belongs_to :user, inverse_of: :user_profile

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:capitalize).join(" ")
  end

  def address
    [street_address_1, street_address_2, city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_1
    [street_address_1].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_2
    [street_address_2].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_3
    [city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(", ")
  end
end
