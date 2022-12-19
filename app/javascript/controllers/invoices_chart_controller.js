import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Connects to data-controller="invoices-chart"
export default class extends Controller {
  static targets = ["chart"]

  static values = {
    categories: Array,
    series: Array
  }

  initialize() {
    this.chart = new ApexCharts(this.chartTarget, this.chartOptions);
    this.chart.render();
  }
  get chartOptions() {
    return {
      chart: {
        height: "400px",
        type: 'line',
      },
      series: [{
        name: 'Invoices',
        data: this.seriesValue
      }],
      xaxis: {
        categories: this.categoriesValue,
        type: 'datetime'
      },
      stroke: {
        curve: "smooth"
      }
    }
  }
}
