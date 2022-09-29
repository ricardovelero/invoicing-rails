class Client < ApplicationRecord
	belongs_to :user
	has_many :invoices

	validates :first_name, :last_name, :nif,
		:street, :city, :region, :postal_code,
		:country, presence: true

	def full_name
		[first_name, last_name].reject(&:blank?).collect(&:capitalize).join(' ')
	end
end
