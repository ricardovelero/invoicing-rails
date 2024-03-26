# frozen_string_literal: true

require 'application_system_test_case'

class ItemsTest < ApplicationSystemTestCase
  setup do
    login_as users(:third)
    @item = items(:first) # Reference to the first fixture item
  end

  test 'showing an item' do
    visit items_path
    click_link @item.item_name

    assert_selector 'h1', text: @item.item_name
  end

  test 'should create item' do
    visit items_path
    click_on 'Nuevo ítem'

    assert_selector 'h1', text: 'Nuevo ítem ✨'
    fill_in 'item[item_name]', with: 'An item'
    fill_in 'item[description]', with: @item.description
    fill_in 'item[price]', with: @item.price
    iva_value = @item.iva.to_s.gsub(/\.0+e\+00$/, '').to_i.to_s
    select iva_value, from: 'item[iva]'
    click_on 'Crear Item'

    assert_text 'Ítem creado con éxito', wait: 3
  end

  test 'should update Item' do
    visit items_path
    click_on 'Editar ítem', match: :first

    fill_in 'item[item_name]', with: @item.item_name
    fill_in 'item[description]', with: @item.description
    fill_in 'item[price]', with: @item.price
    iva_value = @item.iva.to_s.gsub(/\.0+e\+00$/, '').to_i.to_s
    select iva_value, from: 'item[iva]'
    click_on 'Actualizar Item'

    assert_text 'Ítem actualizado con éxito', wait: 3
  end

  # test 'should destroy Item' do
  #   visit items_path
  #   assert_text @item.item_name

  #   accept_alert '¿Estás seguro?' do
  #     click_on 'Borrar ítem', match: :first
  #   end

  #   assert_text 'Ítem eliminado con éxito'
  # end
end
