# frozen_string_literal: true

class ApplicationController < ActionController::Base # rubocop:disable Style/Documentation
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :config_devise_params, if: :devise_controller?
  before_action { @pagy_locale = params[:locale] }
  around_action :switch_locale
  after_action :store_action
  layout :layout_by_resource
  protect_from_forgery with: :exception

  include Pagy::Backend

  protected

  def after_sign_in_path_for(_resource_or_scope)
    "/dashboard?locale=#{I18n.locale}"
    # stored_location_for(resource_or_scope) || super
  end

  def after_sign_out_path_for(_resource_or_scope)
    '/'
  end

  def store_action # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    return unless request.get?

    if request.path != '/users/sign_in' && request.path != '/users/sign_up' &&
       request.path != '/users/password/new' &&
       request.path != '/users/password/edit' &&
       request.path != '/users/confirmation' &&
       request.path != '/users/sign_out' && !request.xhr?
      # don't store ajax calls
      store_location_for(:user, request.fullpath)
    end
  end

  def config_devise_params # rubocop:disable Metrics/MethodLength
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: %i[
        first_name
        last_name
        email
        password
        password_confirmation
        user_profile_attributes
      ]
    )
  end

  def switch_locale(&action) # rubocop:disable Metrics/AbcSize
    locale = I18n.available_locales.include?(params[:locale].to_s.strip.to_sym) ? params[:locale] : (user_signed_in? ? current_user.user_profile.locale : I18n.default_locale) # rubocop:disable Style/NestedTernaryOperator,Layout/LineLength

    I18n.with_locale(locale, &action)
    Carmen.i18n_backend.locale = locale
  end

  private

  def member_controller?
    return false if controller_path == 'home'

    true
  end

  def layout_by_resource
    return 'session' if session_layout_needed?
    return 'home' if home_layout_needed?

    'application'
  end

  def session_layout_needed?
    devise_controller? && resource_name == :user &&
      (action_name == 'new' || action_name == 'create' || action_name == 'password')
  end

  def home_layout_needed?
    controller_name == 'home' && action_name == 'index'
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
