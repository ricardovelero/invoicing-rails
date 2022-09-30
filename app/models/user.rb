class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :lockable,
         :timeoutable,
         :trackable

  validates_uniqueness_of :email
  validates :email, :encrypted_password, presence: true
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP,
    message: "must be a valid email address"

  has_many :invoices
  has_many :clients
  has_many :items
end
