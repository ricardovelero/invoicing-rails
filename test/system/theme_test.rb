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
end
