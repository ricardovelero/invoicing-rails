# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Facturacion
  class Application < Rails::Application # rubocop:disable Style/Documentation
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Madrid'
    # config.eager_load_paths << Rails.root.join("extras")

    config.to_prepare { Devise::Mailer.layout 'mailer' }

    config.i18n.raise_on_missing_translations = true

    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = {
      api_token: Rails.application.credentials.postmark_api_token
    }
  end
end
