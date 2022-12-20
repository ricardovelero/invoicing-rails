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
    this.chart = new ApexCharts(this.chartTarget, this.chartOptions);
    this.chart.render();
  }

  disconnect() {
    this.chart.destroy();
  }

}
