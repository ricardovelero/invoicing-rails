# frozen_string_literal: true

I18n.load_path += Dir[Rails.root.join('lib', 'locales', '**', '*.{rb,yml}')]

# Permitted locales available for the application
I18n.available_locales = %i[es en]

# Set default locale to something other than :en
I18n.default_locale = :es
