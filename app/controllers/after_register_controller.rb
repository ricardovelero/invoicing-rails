class AfterRegisterController < ApplicationController
  include Wicked::Wizard

  layout "onboarding"

  before_action :authenticate_user!

  steps(*User.new.form_steps)

  def show
    @user = current_user
    case step
    when "sign_up"
      skip_step if @user.persisted?
    when "freelance_or_company"
      @user_profile = get_user_profile
    when "set_name"
      @user_profile = get_user_profile
    when "set_address"
      @user_profile = get_user_profile
    end

    render_wizard
  end

  def update
    @user = current_user
    case step
    when "freelance_or_company"
      if @user.create_user_profile(onboarding_params(step).except(:form_step))
        render_wizard @user_profile = get_user_profile
      else
        @user_profile.destroy
        render_wizard @user, status: :unprocessable_entity
      end
    when "set_name"
      if @user.user_profile.update(onboarding_params(step).except(:form_step))
        render_wizard @user_profile = get_user_profile
      else
        render_wizard @user, status: :unprocessable_entity
      end
    when "set_address"
      if @user.user_profile.update(onboarding_params(step).except(:form_step))
        render_wizard @user_profile = get_user_profile
      else
        @user_profile.destroy
        render_wizard @user, status: :unprocessable_entity
      end
    end
  end

  private

  def finish_wizard_path
    "/dashboard"
  end

  def get_user_profile
    @user.user_profile.nil? ? UserProfile.new : @user.user_profile
  end

  def onboarding_params(step = "sign_up")
    permitted_attributes =
      case step
      when "freelance_or_company"
        required_parameters = :user_profile
        %i[is_freelance user_id]
      when "set_name"
        required_parameters = :user_profile
        %i[first_name last_name gov_id]
      when "set_address"
        required_parameters = :user_profile
        %i[
          company_name
          street_address_1
          street_address_2
          city
          region
          postal_code
          country
          phone
        ]
      end
    params
      .require(required_parameters)
      .permit(:id, permitted_attributes)
      .merge(form_step: step)
  end
end
