# frozen_string_literal: true

class ChargesController < ApplicationController # rubocop:disable Style/Documentation
  before_action :authenticate_user!
  before_action :amount_to_be_charged
  before_action :description

  def new; end

  def create
    customer = StripeTool.create_customer(email: params[:stripeEmail], stripe_token: params[:stripeToken])

    StripeTool.create_charge(
      customer_id: customer.id, amount: @amount, description: @description, currency: 'eur'
    )
    redirect_to thanks_path
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end

  def thanks; end

  private

  def amount_to_be_charged
    @amount = 500
  end

  def description
    @description = 'Subscripción mensual'
  end
end
