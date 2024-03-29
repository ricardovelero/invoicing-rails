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
  validates_format_of :email,
                      with: URI::MailTo::EMAIL_REGEXP,
                      message: "must be a valid email address"

  has_many :invoices, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :items, dependent: :destroy
  has_one :user_profile, dependent: :destroy, inverse_of: :user

  #accepts_nested_attributes_for :user_profile, allow_destroy: true

  mattr_accessor :form_steps do
    %w[sign_up freelance_or_company set_name set_address]
  end

  attr_accessor :form_step

  def form_step
    @form_step ||= "sign_up"
  end

  # with_options if: -> { required_for_step?("set_name") } do |step|
  #   step.validates :first_name, presence: true
  #   step.validates :last_name, presence: true
  # end

  validates_associated :user_profile,
                        if: -> { required_for_step?("set_name") }

  validates_associated :user_profile,
                       if: -> { required_for_step?("set_address") }
  validates_associated :user_profile,
                       if: -> { required_for_step?("freelance_or_company") }

  def required_for_step?(step)
    #All fields are required if no form is present
    form_step.nil?

    # All fields from previous steps are required if the
    # step parameter appears before or we are on the current step
    form_steps.index(step.to_s) <= form_steps.index(form_step.to_s)
  end

  def user_profile
    super || build_user_profile
  end

end
