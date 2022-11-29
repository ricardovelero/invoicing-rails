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
  gov_id: "1234567890C",
  is_freelance: true,
  street_address_1: "123 Main ST",
  city: "Estepona",
  region: "Malaga",
  postal_code: "29680",
  country: "España",
  first_name: "Dean",
  last_name: "DeHart",
  user: dean
).save!

UserProfile.new(
  gov_id: "9876543210C",
  is_freelance: true,
  street_address_1: "123 Main ST",
  city: "Estepona",
  region: "Malaga",
  postal_code: "29680",
  country: "España",
  first_name: "John",
  last_name: "Smith",
  user: john
).save!

