import ChartsController from './charts_controller'

export default class extends ChartsController {

  get chartOptions() {
    return {
      chart: {
        type: 'pie',
        height: '400px'
      },
      series: this.seriesValue,
      labels: this.labelsValue,
    }
  }
}
