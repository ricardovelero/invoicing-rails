# frozen_string_literal: true

require 'application_system_test_case'

class SidebarTest < ApplicationSystemTestCase
  setup do
    login_as users(:third)
    page.current_window.resize_to(1400, 1400)
    visit items_path
    page.execute_script('localStorage.clear(); sessionStorage.clear()')
    page.refresh
    click_button 'Expand / collapse sidebar'
    assert_selector 'body.sidebar-expanded'
  end

  test 'submenu stays open after selecting an option' do
    within '#sidebar' do
      click_link 'Ítems', exact: true
      assert_link 'Listado Ítems'
      click_link 'Nuevo ítem', exact: true
    end

    assert_current_path new_item_path, ignore_query: true
    assert_selector 'h1', text: 'Nuevo ítem'
    within '#sidebar' do
      assert_link 'Listado Ítems'
      assert_link 'Nuevo ítem'
      click_link 'Listado Ítems'
    end

    assert_current_path items_path, ignore_query: true
    assert_selector 'h1', text: 'Ítems'
    assert_selector '#sidebar a', text: 'Nuevo ítem'
  end

  [
    ['Facturas', 'Series', :invoice_series_index_path, 'Listado Facturas', 'Series'],
    ['Clientes', 'Nuevo Cliente', :new_client_path, 'Listado Clientes', 'Nuevo Cliente'],
    ['Ajustes', 'Mi Cuenta', :edit_user_registration_path, 'Notificaciones', 'Ajustes de tu Cuenta']
  ].each do |menu, option, path, sibling, heading|
    test "#{menu} submenu stays open after navigation" do
      within '#sidebar' do
        click_link menu, exact: true
        click_link option, exact: true
      end

      assert_current_path public_send(path), ignore_query: true
      assert_selector 'main h1', text: heading
      within '#sidebar' do
        assert_link sibling
        assert_link option
      end
    end
  end

  test 'clicking the page closes the submenu and keeps it closed after a reload' do
    within '#sidebar' do
      click_link 'Ítems', exact: true
      assert_link 'Listado Ítems'
    end

    find('main h1').click
    assert_no_selector '#sidebar a', text: 'Listado Ítems'
    page.refresh
    assert_no_selector '#sidebar a', text: 'Listado Ítems'
  end

  test 'opening another submenu closes the previous one' do
    within '#sidebar' do
      click_link 'Ítems', exact: true
      assert_link 'Listado Ítems'
      click_link 'Clientes', exact: true
      assert_link 'Listado Clientes'
      assert_no_link 'Listado Ítems'
    end
  end

  test 'toggling a submenu closed keeps it closed after a reload' do
    within '#sidebar' do
      click_link 'Ítems', exact: true
      assert_link 'Listado Ítems'
      click_link 'Ítems', exact: true
      assert_no_link 'Listado Ítems'
    end

    page.refresh
    assert_no_selector '#sidebar a', text: 'Listado Ítems'
  end

  test 'mobile sidebar stays open after navigation and closes on an outside click' do
    page.current_window.resize_to(390, 844)
    click_button 'Abrir Menú'
    within '#sidebar' do
      click_link 'Ítems', exact: true
      click_link 'Nuevo ítem', exact: true
    end

    assert_current_path new_item_path, ignore_query: true
    assert_selector 'h1', text: 'Nuevo ítem'
    assert_selector 'button[aria-controls="sidebar"][aria-expanded="true"]'
    within '#sidebar' do
      assert_link 'Listado Ítems'
    end

    find('#sidebar').find(:xpath, 'preceding-sibling::div').click(x: 100, y: 0, offset: :center)
    assert_selector 'button[aria-controls="sidebar"][aria-expanded="false"]'
    click_button 'Abrir Menú'
    assert_no_selector '#sidebar a', text: 'Listado Ítems'
  end

  test 'drawer and rail remain usable when browser storage is blocked' do
    page.execute_script <<~JS
      window.sidebarStorageGetItem = Storage.prototype.getItem;
      window.sidebarStorageSetItem = Storage.prototype.setItem;
      Storage.prototype.getItem = function() { throw new DOMException('Storage blocked', 'SecurityError'); };
      Storage.prototype.setItem = function() { throw new DOMException('Storage blocked', 'SecurityError'); };
      const sidebar = window.Stimulus.getControllerForElementAndIdentifier(document.body, 'sidebar');
      sidebar.restored = false;
      sidebar.connect();
      document.querySelectorAll('[data-controller="submenu"]').forEach((element) => {
        const submenu = window.Stimulus.getControllerForElementAndIdentifier(element, 'submenu');
        submenu.restored = false;
        submenu.connect();
      });
    JS

    assert_no_selector 'body.sidebar-expanded'
    click_button 'Expand / collapse sidebar'
    assert_selector 'body.sidebar-expanded'
    within '#sidebar' do
      click_link 'Ítems', exact: true
      assert_link 'Listado Ítems'
    end

    page.current_window.resize_to(390, 844)
    click_button 'Abrir Menú'
    assert_selector 'button[aria-controls="sidebar"][aria-expanded="true"]'
  ensure
    page.execute_script <<~JS
      if (window.sidebarStorageGetItem) {
        Storage.prototype.getItem = window.sidebarStorageGetItem;
        Storage.prototype.setItem = window.sidebarStorageSetItem;
        delete window.sidebarStorageGetItem;
        delete window.sidebarStorageSetItem;
      }
    JS
  end
end
