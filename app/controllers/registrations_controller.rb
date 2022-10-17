# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def update
    unless current_user.user_profile
      current_user.build_user_profile(user_profile_params)
    end
    current_user.user_profile.update(user_profile_params)
    super
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  end

  def after_update_path_for(resource)
    "/users/edit/"
  end

  def after_inactive_sign_up_path_for(resource)
    "/" # Or :prefix_to_your_route
  end

  def after_sign_up_path_for(resource)
    after_register_path(:freelance_or_company)
  end

  private

  def user_profile_params
    params.require(:user_profile).permit(
      :id,
      :first_name,
      :last_name,
      :street_address_1,
      :street_address_2,
      :city,
      :region,
      :postal_code,
      :country,
      :phone,
      :gov_id,
      :user_id,
      :is_freelance,
      :company_name
    )
  end
end
