require "test_helper"

class UserProfileTest < ActiveSupport::TestCase
  fixtures :user_profiles
  test "user profile is not valid without a unique gov_id" do
    user_profile =
      UserProfile.new(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        gov_id: user_profiles(:one).gov_id,
        street_address_1: Faker::Address.street_name,
        street_address_1: Faker::Address.secondary_address,
        city: Faker::Address.city,
        region: %w[Álava Albacete Alicante Almería Ávila Badajoz Baleares Barcelona Burgos Cuenca Cáceres Cádiz Córdoba Gipuzkoa Girona Granada Guadalajara Huelva Huesca Jaén León Lleida Lugo Madrid Murcia Málaga Navarra Ourense Palencia Pontevedra Salamanca Segovia Sevilla Soria Tarragona Teruel Toleda Valladolid Zamora Zaragoza].sample, #Faker::Address.state,
        postal_code: Faker::Address.zip,
        country: "ES", #Faker::Address.country,
        email: Faker::Internet.email(name: :first_name),
        phone: Faker::PhoneNumber.cell_phone_in_e164,
        user_id: 1, #rand(1..2)
      )
    assert user_profile.invalid?
    assert_equal [I18n.translate("errors.messages.taken")], user_profile.errors[:gov_id]
  end
  test "street addresses cannot be more than 70 characters" do
    user_profile = user_profiles(:two)
    assert user_profile.invalid?
    assert_equal ["es demasiado largo (70 caracteres máximo)"], user_profile.errors[:street_address_1]
    assert_equal ["es demasiado largo (70 caracteres máximo)"], user_profile.errors[:street_address_2]
    user_profile = user_profiles(:one)
    assert user_profile.save, "Street Address too long"
  end

  test "user_profile First and Last Name, City, Region, Country cannot be more than 50 characters" do
    user_profile = user_profiles(:two)
    assert user_profile.invalid?
    assert_equal ["es demasiado largo (50 caracteres máximo)"], user_profile.errors[:first_name]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], user_profile.errors[:last_name]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], user_profile.errors[:city]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], user_profile.errors[:region]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], user_profile.errors[:country]
    user_profile = user_profiles(:one)
    assert user_profile.save, "First or Last Name too long"
  end

  test "user_profile gov_id cannot be more than 12 characters" do
    user_profile = user_profiles(:two)
    assert user_profile.invalid?
    assert_equal ["es demasiado largo (12 caracteres máximo)"], user_profile.errors[:gov_id]
    user_profile = user_profiles(:one)
    assert user_profile.save, "gov_id too long"
  end
end
