# frozen_string_literal: true

class Client < ApplicationRecord # rubocop:disable Style/Documentation
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

  validates :nif, uniqueness: true

  validates :street, length: { maximum: 70 }
  validates :first_name, :last_name, :city, :region, :country, length: { maximum: 50 }
  validates :nif, :postal_code, length: { maximum: 12 }

  pg_search_scope :search,
                  against: %i[first_name last_name nif city region country],
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  def full_name
    [first_name, last_name].reject(&:blank?).collect(&:titleize).join(' ')
  end

  def address
    [street, city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(', ')
  end

  def address_line1
    [street].reject(&:blank?).collect(&:titleize).join(', ')
  end

  def address_line2
    [city, postal_code, region, country].reject(&:blank?).collect(&:titleize).join(', ')
  end

  def to_combobox_display
    full_name # or `title`, `to_s`, etc.
  end
end
