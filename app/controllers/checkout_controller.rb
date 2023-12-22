# frozen_string_literal: true

# The Checkout controller for Stripe
class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def show
    current_user.processor = :stripe
    current_user.customer

    @checkout_session = current_user.payment_processor.checkout(
      mode: 'payment',
      line_items: 'mensual_normal'
    )
  end
end
