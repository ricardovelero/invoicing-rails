class Client < ApplicationRecord
  belongs_to :user
  has_many :invoices

  validates :first_name,
            :last_name,
            :nif,
            :street,
            :city,
            :region,
            :postal_code,
            :country,
            presence: true
    
  pg_search_scope :search, against: [:first_name, :last_name, :nif, :city, :region, :country],
  using: { tsearch: { prefix: true } }          

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:capitalize).join(" ")
  end

  def address
    [street, city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_1
    [street].reject(&:blank?).collect(&:titleize).join(", ")
  end

  def address_line_2
    [city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(", ")
  end
end
