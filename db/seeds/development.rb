# frozen_string_literal: true

# Rails truncates on its own. This used database_cleaner, which reached for
# connection.schema_migration -- removed in Rails 7.2.
ActiveRecord::Base.connection.truncate_tables(
  *ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata]
)

dean = User.new(
  email: 'dean@example.com',
  password: 'password',
  password_confirmation: 'password'
)
dean.skip_confirmation!
dean.save!

john = User.new(
  email: 'john@example.com',
  password: 'password',
  password_confirmation: 'password'
)
john.skip_confirmation!
john.save!

UserProfile.new(
  gov_id: Faker::IDNumber.spanish_citizen_number,
  is_freelance: true,
  street_address_1: Faker::Address.street_name,
  street_address_2: Faker::Address.secondary_address,
  city: Faker::Address.city,
  region: %w[Álava Albacete Alicante Almería Ávila Badajoz Baleares Barcelona Burgos Cuenca Cáceres Cádiz Córdoba Gipuzkoa Girona Granada Guadalajara Huelva Huesca Jaén León Lleida Lugo Madrid Murcia Málaga Navarra Ourense Palencia Pontevedra Salamanca Segovia Sevilla Soria Tarragona Teruel Toleda Valladolid Zamora Zaragoza].sample, # Faker::Address.state,
  postal_code: Faker::Address.zip,
  country: 'ES', # Faker::Address.country,
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  user: dean
).save!

UserProfile.new(
  gov_id: Faker::IDNumber.spanish_citizen_number,
  is_freelance: true,
  street_address_1: Faker::Address.street_name,
  street_address_2: Faker::Address.secondary_address,
  city: Faker::Address.city,
  region: %w[Álava Albacete Alicante Almería Ávila Badajoz Baleares Barcelona Burgos Cuenca Cáceres Cádiz Córdoba Gipuzkoa Girona Granada Guadalajara Huelva Huesca Jaén León Lleida Lugo Madrid Murcia Málaga Navarra Ourense Palencia Pontevedra Salamanca Segovia Sevilla Soria Tarragona Teruel Toleda Valladolid Zamora Zaragoza].sample, # Faker::Address.state,
  postal_code: Faker::Address.zip,
  country: 'ES', # Faker::Address.country,
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  user: john
).save!

200.times do |_i|
  Client.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    nif: Faker::IDNumber.spanish_citizen_number,
    street: Faker::Address.street_name,
    city: Faker::Address.city,
    region: %w[Álava Albacete Alicante Almería Ávila Badajoz Baleares Barcelona Burgos Cuenca Cáceres Cádiz Córdoba Gipuzkoa Girona Granada Guadalajara Huelva Huesca Jaén León Lleida Lugo Madrid Murcia Málaga Navarra Ourense Palencia Pontevedra Salamanca Segovia Sevilla Soria Tarragona Teruel Toleda Valladolid Zamora Zaragoza].sample, # Faker::Address.state,
    postal_code: Faker::Address.zip,
    country: 'ES', # Faker::Address.country,
    email: Faker::Internet.email(name: :first_name),
    telephone: Faker::PhoneNumber.cell_phone_in_e164,
    active: 1, # rand(0..1),
    user: dean
  )
end

300.times do |_i|
  Item.create(
    item_name: Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4),
    description: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4),
    price: Faker::Number.within(range: 1.0..2000.0),
    iva: %w[0 4 10 21].sample,
    user: dean
  )
end

# Invoices take the path the app takes: born a draft, filled with line items,
# totalled, and only then issued, so the series hands out the Number. Dates
# climb with the chain because Issue refuses to number an invoice that predates
# the last one in its series.
clients = Client.where(user: dean).to_a
items = Item.where(user: dean).to_a

100.times do |i|
  date = (100 - i).days.ago.to_date

  invoice = Invoice.create!(
    date:,
    due_date: date + 30,
    notes: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4),
    client: clients.sample,
    user: dean
  )

  rand(1..5).times do
    item = items.sample
    quantity = rand(1..12)

    invoice.line_items.create!(
      item:,
      quantity:,
      price: item.price,
      iva: item.iva,
      total: quantity * item.price * (1 + item.iva / 100)
    )
  end

  # Totals have to land while the invoice is still a draft: they freeze on issue.
  invoice.update!(subtotal: invoice.sum_subtotal, iva: invoice.sum_iva, total: invoice.sum_total)

  # The last ten stay drafts so the draft list and the Issue button have
  # something to act on.
  next if i >= 90

  Invoice.transaction { invoice.issue! }
  invoice.update!(status: 'pagada') if rand < 0.5
end
