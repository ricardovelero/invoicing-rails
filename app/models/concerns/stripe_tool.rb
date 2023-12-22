# frozen_string_literal: true

# Stripe helper module to create customer and create charge
module StripeTool
  def self.create_customer(email: nil, stripe_token: nil)
    Stripe::Customer.create(email:, source: stripe_token)
  end

  def self.create_charge(customer_id: nil, amount: nil, description: nil, currency: 'eur')
    Stripe::Charge.create(customer: customer_id, amount:, description:, currency:)
  end
end
