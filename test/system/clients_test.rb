require "application_system_test_case"

class ClientsTest < ApplicationSystemTestCase
  setup { @client = clients(:one) }

  test "visiting the index" do
    visit clients_url
    assert_selector "h1", text: "Clients"
  end

  test "should create client" do
    visit clients_url
    click_on "New client"

    check "Active" if @client.active
    fill_in "City", with: @client.city
    fill_in "Country", with: @client.country
    fill_in "Email", with: @client.email
    fill_in "Last name", with: @client.last_name
    fill_in "First name", with: @client.first_name
    fill_in "Nif", with: @client.nif
    fill_in "Postal code", with: @client.postal_code
    fill_in "Region", with: @client.region
    fill_in "Street", with: @client.street
    fill_in "Telephone", with: @client.telephone
    click_on "Create Client"

    assert_text "Client was successfully created"
    click_on "Back"
  end

  test "should update Client" do
    visit client_url(@client)
    click_on "Edit this client", match: :first

    check "Active" if @client.active
    fill_in "City", with: @client.city
    fill_in "Country", with: @client.country
    fill_in "Email", with: @client.email
    fill_in "Last name", with: @client.last_name
    fill_in "First name", with: @client.first_name
    fill_in "Nif", with: @client.nif
    fill_in "Postal code", with: @client.postal_code
    fill_in "Region", with: @client.region
    fill_in "Street", with: @client.street
    fill_in "Telephone", with: @client.telephone
    click_on "Update Client"

    assert_text "Client was successfully updated"
    click_on "Back"
  end

  test "should destroy Client" do
    visit client_url(@client)
    click_on "Destroy this client", match: :first

    assert_text "Client was successfully destroyed"
  end
end
