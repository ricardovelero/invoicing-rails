require "test_helper"

class ClientTest < ActiveSupport::TestCase
  fixtures :clients
  test "client attributes must not be empty" do
    client = Client.new
    client.user_id = 1
    assert client.invalid?
    assert client.errors[:first_name].any?
    assert client.errors[:last_name].any?
    assert client.errors[:nif].any?
    assert client.errors[:street].any?
    assert client.errors[:region].any?
    assert client.errors[:postal_code].any?
    assert client.errors[:country].any?
  end

  test "street address cannot be more than 70 characters" do
    client = clients(:two)
    assert client.invalid?
    assert_equal ["es demasiado largo (70 caracteres máximo)"], client.errors[:street]
    client = clients(:one)
    assert client.save, "Street Address too long"
  end

  test "client First and Last Name cannot be more than 50 characters" do
    client = clients(:two)
    assert client.invalid?
    assert_equal ["es demasiado largo (50 caracteres máximo)"], client.errors[:first_name]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], client.errors[:last_name]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], client.errors[:city]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], client.errors[:region]
    assert_equal ["es demasiado largo (50 caracteres máximo)"], client.errors[:country]
    client = clients(:one)
    assert client.save, "First or Last Name too long"
  end

  test "client nif cannot be more than 12 characters" do
    client = clients(:two)
    assert client.invalid?
    assert_equal ["es demasiado largo (12 caracteres máximo)"], client.errors[:nif]
    client = clients(:one)
    assert client.save, "NIF too long"
  end

  test "client is not valid without a unique nif" do
    client =
      Client.new(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        nif: clients(:one).nif,
        street: Faker::Address.street_name,
        city: Faker::Address.city,
        region: %w[Álava Albacete Alicante Almería Ávila Badajoz Baleares Barcelona Burgos Cuenca Cáceres Cádiz Córdoba Gipuzkoa Girona Granada Guadalajara Huelva Huesca Jaén León Lleida Lugo Madrid Murcia Málaga Navarra Ourense Palencia Pontevedra Salamanca Segovia Sevilla Soria Tarragona Teruel Toleda Valladolid Zamora Zaragoza].sample, #Faker::Address.state,
        postal_code: Faker::Address.zip,
        country: "ES", #Faker::Address.country,
        email: Faker::Internet.email(name: :first_name),
        telephone: Faker::PhoneNumber.cell_phone_in_e164,
        active: 1, #rand(0..1),
        user_id: 1, #rand(1..2)
      )
    assert client.invalid?
    assert_equal [I18n.translate("errors.messages.taken")], client.errors[:nif]
  end

end
