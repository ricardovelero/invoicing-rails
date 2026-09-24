# frozen_string_literal: true

require 'application_system_test_case'

class ThemeTest < ApplicationSystemTestCase
  setup do
    login_as users(:first)
  end

  test 'both dashboard charts render' do
    visit dashboard_path

    assert_selector '#invoices-chart-container .apexcharts-line'
    assert_selector '#paid-vs-unpaid-chart-container .apexcharts-pie'
  end

  test 'theme toggle updates charts and persists across navigation' do
    visit dashboard_path
    page.execute_script("localStorage.setItem('theme', 'light')")
    page.refresh

    assert_selector 'html:not(.dark)'
    assert_selector 'button[data-controller="theme"][aria-pressed="false"]'
    assert_selector '#invoices-chart-container .apexcharts-line'
    assert_selector '#paid-vs-unpaid-chart-container .apexcharts-pie'

    click_button 'Modo oscuro'

    assert_selector 'html.dark'
    assert_selector 'button[data-controller="theme"][aria-pressed="true"]'
    assert_selector '#invoices-chart-container .apexcharts-tooltip.apexcharts-theme-dark', visible: :all
    assert_selector '#paid-vs-unpaid-chart-container .apexcharts-tooltip.apexcharts-theme-dark', visible: :all
    assert_selector '#paid-vs-unpaid-chart-container .apexcharts-pie'

    click_button 'Modo oscuro'
    assert_selector 'html:not(.dark)'
    assert_selector '#paid-vs-unpaid-chart-container .apexcharts-tooltip.apexcharts-theme-light', visible: :all
    assert_selector '#paid-vs-unpaid-chart-container .apexcharts-pie'

    click_button 'Modo oscuro'
    visit items_path
    assert_selector 'h1', text: 'Ítems'
    assert_selector 'html.dark'
    page.refresh
    assert_selector 'html.dark'
    assert_selector 'button[data-controller="theme"][aria-pressed="true"]'
  end

  test 'sidebar follows the selected theme' do
    visit items_path
    page.execute_script("localStorage.setItem('theme', 'light')")
    page.refresh

    assert_selector 'html:not(.dark)'
    assert_sidebar_color 'rgb(255, 255, 255)', 'backgroundColor'
    assert_equal 'rgb(30, 41, 59)', sidebar_color('color', '.sidebar_link')
    assert_equal 'rgb(100, 116, 139)', sidebar_color('color', '.sidebar_link_secondary')
    active_icon = '[data-submenu-key-value="sidebar-submenu-items"] [data-active-class="text-sidebar-icon-active-soft"]'
    light_icon_color = sidebar_color('color', active_icon)

    click_button 'Modo oscuro'

    assert_selector 'html.dark'
    assert_sidebar_color 'rgb(30, 41, 59)', 'backgroundColor'
    assert_equal 'rgb(226, 232, 240)', sidebar_color('color', '.sidebar_link')
    assert_equal 'rgb(148, 163, 184)', sidebar_color('color', '.sidebar_link_secondary')
    refute_equal light_icon_color, sidebar_color('color', active_icon)

    click_button 'Modo oscuro'
    assert_sidebar_color 'rgb(255, 255, 255)', 'backgroundColor'
  end

  private

  def sidebar_color(property, selector = '#sidebar')
    page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json})).#{property}")
  end

  def assert_sidebar_color(expected, property)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + Capybara.default_max_wait_time
    actual = sidebar_color(property)
    until actual == expected || Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
      sleep 0.02
      actual = sidebar_color(property)
    end
    assert_equal expected, actual
  end
end
