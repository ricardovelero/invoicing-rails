# frozen_string_literal: true

# Represents a customer and their current billing and tax information.
class Client < ApplicationRecord
  belongs_to :user

  has_many :invoices, dependent: :restrict_with_error

  validates :first_name,
            :last_name,
            :nif,
            :street,
            :city,
            :region,
            :postal_code,
            :country,
            presence: true

  validates :nif, uniqueness: { scope: :user_id }

  validates :street, length: { maximum: 70 }
  validates :first_name,
            :last_name,
            :city,
            :region,
            :country,
            length: { maximum: 50 }

  validates :nif, :postal_code, length: { maximum: 12 }

  before_validation :normalize_nif

  pg_search_scope :search,
                  against: %i[first_name last_name nif city region country],
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  def full_name
    [first_name, last_name].compact_blank.join(' ')
  end

  def address
    [street, city, postal_code, region, country].compact_blank.join(', ')
  end

  def address_line1
    street
  end

  def address_line2
    [city, postal_code, region, country].compact_blank.join(', ')
  end

  private

  def normalize_nif
    self.nif = nif&.strip&.upcase
  end
end
