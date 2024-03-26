# frozen_string_literal: true

require 'application_system_test_case'

class ItemsTest < ApplicationSystemTestCase
  setup do
    login_as users(:third)
    @item = items(:first) # Reference to the first fixture item
  end

  test 'Showing an item' do
    visit items_path
    click_link @item.name

    assert_selector 'h1', text: @item.name
  end

  test 'Should create item' do
    visit items_path
    click_on 'Nuevo Ítem'

    fill_in 'Description', with: @item.description
    fill_in 'Price', with: @item.price
    fill_in 'IVA', with: @item.iva
    fill_in 'IRPF', with: @item.irpf
    fill_in 'Item name', with: @item.item_name
    click_on 'Crear Item'

    assert_text 'Item was successfully created'
    click_on 'Back'
  end

  test 'should update Item' do
    visit items_path
    click_on 'Edit this item', match: :first

    fill_in 'Description', with: @item.description
    fill_in 'Price', with: @item.price
    fill_in 'IVA', with: @item.iva
    fill_in 'IRPF', with: @item.irpf
    fill_in 'Item name', with: @item.item_name
    click_on 'Update Item'

    assert_text 'Item was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Item' do
    visit items_path
    assert_text @item.item_name

    accept_alert '¿Estás seguro?' do
      click_on 'Borrar', match: :first
    end

    assert_text 'Ítem eliminado con éxito'
  end
end
