require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = clients(:one)
    sign_in users(:first)
  end

  test "should get index" do
    get clients_url
    assert_response :success
  end

  test "should get new" do
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      post clients_url,
           params: {
             client: {
               active: @client.active,
               city: @client.city,
               country: @client.country,
               email: @client.email,
               last_name: @client.last_name,
               first_name: @client.first_name,
               nif: "NIF#{rand(100_000)}",
               postal_code: @client.postal_code,
               region: @client.region,
               street: @client.street,
               telephone: @client.telephone
             }
           }
    end

    assert_redirected_to clients_url(locale: I18n.locale)
  end

  test "should show client" do
    get client_url(@client)
    assert_response :success
  end

  test "should get edit" do
    get edit_client_url(@client)
    assert_response :success
  end

  test "should update client" do
    patch client_url(@client),
          params: {
            client: {
              active: @client.active,
              city: @client.city,
              country: @client.country,
              email: @client.email,
              last_name: @client.last_name,
              first_name: @client.first_name,
              nif: @client.nif,
              postal_code: @client.postal_code,
              region: @client.region,
              street: @client.street,
              telephone: @client.telephone
            }
          }
    assert_redirected_to clients_url(locale: I18n.locale)
  end

  test "should destroy client" do
    assert_difference("Client.count", -1) { delete client_url(@client) }

    assert_redirected_to clients_url(locale: I18n.locale)
  end
end
