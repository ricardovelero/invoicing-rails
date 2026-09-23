import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Connects to data-controller="charts"
export default class extends Controller {
  static targets = ["chart"]

  static values = {
    labels: Array,
    series: Array
  }

  connect() {
    this.chart = new ApexCharts(this.chartTarget, {
      ...this.chartOptions,
      ...this.themeOptions
    })
    this.chart.render()
  }

  disconnect() {
    this.teardown()
  }

  applyTheme() {
    this.chart?.updateOptions(this.themeOptions)
  }

  teardown() {
    this.chart?.destroy()
    this.chart = null
  }

  get themeOptions() {
    const dark = document.documentElement.classList.contains("dark")

    return {
      chart: {
        background: "transparent",
        foreColor: this.color("--muted-foreground")
      },
      theme: {
        mode: dark ? "dark" : "light"
      },
      grid: {
        borderColor: this.color("--border")
      },
      tooltip: {
        theme: dark ? "dark" : "light"
      }
    }
  }

  color(token) {
    const value = getComputedStyle(document.documentElement)
      .getPropertyValue(token)
      .trim()

    return `hsl(${value})`
  }

}
