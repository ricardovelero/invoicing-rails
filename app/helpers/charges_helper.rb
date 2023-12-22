# frozen_string_literal: true

# Helpers for Stripe implementation
module ChargesHelper
  def pretty_amount(amount_in_cents)
    number_to_currency(amount_in_cents / 100)
  end
end
