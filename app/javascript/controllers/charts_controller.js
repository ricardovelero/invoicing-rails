import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Connects to data-controller="charts"
export default class extends Controller {
  static targets = ["chart"]

  static values = {
    labels: Array,
    series: Array
  }

  initialize() {
    this.themeChanged = this.applyTheme.bind(this)
    this.chart = new ApexCharts(this.chartTarget, {
      ...this.chartOptions,
      ...this.themeOptions
    });
    this.chart.render();
  }

  connect() {
    document.addEventListener("theme:changed", this.themeChanged)
  }

  disconnect() {
    document.removeEventListener("theme:changed", this.themeChanged)
    this.chart.destroy();
  }

  applyTheme() {
    this.chart.updateOptions(this.themeOptions)
  }

  get themeOptions() {
    const dark = document.documentElement.classList.contains("dark")

    return {
      chart: {
        background: "transparent",
        foreColor: this.color("--muted-foreground")
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
