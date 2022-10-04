class ApplicationController < ActionController::Base
  layout :layout_by_resource
  before_action :config_devise_params, if: :devise_controller?
  around_action :switch_locale

  protect_from_forgery with: :exception

  private

    def member_controller?
      return false if controller_path == "home"

      true
    end

    def layout_by_resource
      case
      when devise_controller? then "session"
      else "application"
      end
    end

  protected

    def after_sign_in_path_for(resource)
      "/dashboard"
    end

    def after_sign_out_path_for(resource_or_scope)
      "/"
    end

    def config_devise_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation
      ])
    end

    def switch_locale(&action)
      logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
      locale = current_user.try(:locale) || params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
      logger.debug "* Locale set to '#{locale}'"
      I18n.with_locale(locale, &action)
    end

    private
      def extract_locale_from_accept_language_header
        request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      end
end
