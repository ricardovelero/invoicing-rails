class AfterRegisterController < ApplicationController
    include Wicked::Wizard

    before_action :authenticate_user!

    steps(*User.new.form_steps)

    def show
        @user = current_user
        case step
        when 'sign_up'
            skip_step if @user.persisted?
        when 'freelance_or_company'
            @user_profile = get_user_profile
        when 'set_name'
            @user = current_user
        when 'set_address'
            @user_profile = get_user_profile
        end

        render_wizard
    end

    def update
        @user = current_user
        case step
        when 'freelance_or_company'
            if @user.create_user_profile(onboarding_params(step).except(:form_step))
                render_wizard @user_profile = get_user_profile
            else
                @user_profile.destroy
                render_wizard @user, status: :unprocessable_entity
            end
        when 'set_name'
            if @user.update(onboarding_params(step))
                render_wizard @user
            else
                render_wizard @user, status: :unprocessable_entity
            end
        when 'set_address'
            if @user.create_user_profile(onboarding_params(step).except(:form_step))
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
            if @user.user_profile.nil?
                UserProfile.new
            else
                @user.user_profile
            end
        end

        def onboarding_params(step = 'sign_up')
            permitted_attributes = case step
                when 'freelance_or_company'
                    required_parameters = :user_profile
                    %i[is_freelance user_id]
                when 'set_name'
                    required_parameters = :user
                    %i[first_name last_name]
                when 'set_address'
                    required_parameters = :user_profile
                    %i[company gov_id street_address_1 street_address_2 city region postal_code country phone]
                end
            params.require(required_parameters).permit(:id, permitted_attributes).merge(form_step: step)
        end

end
