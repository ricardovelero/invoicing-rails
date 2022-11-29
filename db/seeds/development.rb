require 'database_cleaner'

DatabaseCleaner.clean_with(:truncation)

dean = User.new(
    email: "dean@example.com",
    password: "password",
    password_confirmation: "password",
  )
  dean.skip_confirmation!
  dean.save!

john = User.new(
    email: "john@example.com",
    password: "password",
    password_confirmation: "password",
  )
  john.skip_confirmation!
  john.save!

UserProfile.new(
  gov_id: Faker::IDNumber.spanish_citizen_number,
  is_freelance: true,
  street_address_1: Faker::Address.street_name,
  street_address_2: Faker::Address.secondary_address,
  city: Faker::Address.city,
  region: Faker::Address.state,
  postal_code: Faker::Address.zip,
  country: Faker::Address.country,
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
  region: Faker::Address.state,
  postal_code: Faker::Address.zip,
  country: Faker::Address.country,
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  user: john
).save!

200.times do |i|
  Client.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    nif: Faker::IDNumber.spanish_citizen_number,
    street: Faker::Address.street_name,
    city: Faker::Address.city,
    region: Faker::Address.state,
    postal_code: Faker::Address.zip,
    country: Faker::Address.country,
    email: Faker::Internet.email(name: :first_name),
    telephone: Faker::PhoneNumber.cell_phone_in_e164,
    active: rand(0..1),
    user_id: rand(1..2)
  )
end

300.times do |i|
  Item.create(
    item_name: Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4),
    description: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4),
    price: Faker::Number.within(range: 1.0..1000.0),
    iva: %w[0 4 10 21].sample,
    irpf: %w[0 7 15].sample,
    user_id: rand(1..2)
  )
end

100.times do |i|
  Invoice.create(
    invoice_number: i,
    date: Faker::Date.between(from: 7.days.ago, to: Date.today),
    due_date: Faker::Date.forward(days: 30),
    notes: Faker::Lorem.paragraph(sentence_count: 2, supplemental: false, random_sentences_to_add: 4),
    status: %w[Pendiente Pagada].sample,
    client_id: rand(1..50),
    user_id: rand(1..2)
  )
end

400.times do |i|
  LineItem.create(
    invoice_id: rand(1..100),
    item_id: rand(1..300),
    quantity: rand(1..12)
  )
end