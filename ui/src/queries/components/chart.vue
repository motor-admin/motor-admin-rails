<template>
  <canvas
    v-if="data.length"
    ref="canvas"
    class="bg-white p-2"
  />
  <div
    v-else
    class="d-flex justify-content-center align-items-center"
    style="height: 100%"
  >
    No data
  </div>
</template>

<script>
import {
  Chart,
  LineController,
  LineElement,
  PointElement,
  LinearScale,
  BarElement,
  BarController,
  CategoryScale,
  PieController,
  ArcElement,
  Legend,
  Tooltip
} from 'chart.js'

import ChartDataLabels from 'chartjs-plugin-datalabels'
import { formatDate } from 'utils/scripts/date_format'
import deepmerge from 'deepmerge'

Chart.register(
  LineController,
  LineElement,
  PointElement,
  LinearScale,
  BarElement,
  BarController,
  CategoryScale,
  PieController,
  ArcElement,
  Legend,
  Tooltip,
  ChartDataLabels
)

const backgroundColors = [
  'rgba(97, 144, 232, 0.6)',
  'rgba(255, 99, 132, 0.6)',
  'rgba(54, 162, 235, 0.6)',
  'rgba(255, 206, 86, 0.6)',
  'rgba(75, 192, 192, 0.6)',
  'rgba(153, 102, 255, 0.6)',
  'rgba(255, 159, 64, 0.6)'
]

const borderColors = [
  'rgba(97, 144, 232, 1)',
  'rgba(255, 99, 132, 1)',
  'rgba(54, 162, 235, 1)',
  'rgba(255, 206, 86, 1)',
  'rgba(75, 192, 192, 1)',
  'rgba(153, 102, 255, 1)',
  'rgba(255, 159, 64, 1)'
]

export default {
  name: 'QueryChart',
  props: {
    data: {
      type: Array,
      required: false,
      default: () => []
    },
    columns: {
      type: Array,
      required: false,
      default: () => []
    },
    chartType: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      chart: null
    }
  },
  computed: {
    transposedData () {
      return this.data[0].map((col, i) => this.data.map(([...row]) => row[i]))
    },
    datasets () {
      return this.transposedData.slice(1, this.transposedData.length).map((data, index) => {
        return {
          label: this.columns[index + 1].title,
          backgroundColor: this.chartType === 'pie' ? backgroundColors : backgroundColors[index],
          borderColor: this.chartType === 'pie' ? '#fff' : borderColors[index],
          borderWidth: this.chartType === 'bar' ? 1 : 2,
          data
        }
      })
    },
    chartParams () {
      return {
        plugins: [ChartDataLabels],
        type: this.chartType,
        data: {
          labels: this.labels,
          datasets: this.datasets
        },
        options: this.options
      }
    },
    options () {
      const options = {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
        plugins: {}
      }

      if (this.chartType !== 'pie' && this.datasets.length === 1) {
        options.plugins = deepmerge(options.plugins, {
          legend: {
            display: false
          }
        })
      }

      if (this.chartType !== 'pie') {
        options.scales = {
          y: {
            grid: {
              display: false
            }
          },
          x: {
            grid: {
              display: false
            }
          }
        }
      }

      options.plugins = deepmerge(options.plugins, {
        datalabels: {
          display: true,
          anchor: 'end',
          align: this.chartType === 'pie' ? 'end' : 'top',
          font: {
            weight: 'bold'
          }
        }
      })

      if (this.chartType === 'pie') {
        options.plugins = deepmerge(options.plugins, {
          datalabels: {
            formatter (value, context) {
              const sum = context.dataset.data.reduce((acc, val) => acc + parseFloat(val), 0)

              return Math.round(value * 10000 / sum, 2) / 100 + '%'
            }
          }
        })
      }

      if (this.chartType !== 'pie' && this.datasets.length === 1) {
        options.layout = {
          padding: {
            top: 25
          }
        }
      }

      return options
    },
    labels () {
      const labelColumn = this.columns[0]
      const labels = this.transposedData[0]

      if (['date', 'datetime'].includes(labelColumn.type)) {
        return labels.map((label) => formatDate(label, { year: 'numeric', month: 'short', day: 'numeric' }))
      } else {
        return labels
      }
    }
  },
  watch: {
    chartType () {
      this.update()
    },
    data () {
      this.update()
    }
  },
  mounted () {
    this.render()
  },
  methods: {
    update () {
      this.chart?.destroy()
      this.render()
    },
    render () {
      if (this.data.length) {
        this.$nextTick(() => {
          this.chart = new Chart(this.$refs.canvas.getContext('2d'), this.chartParams)
        })
      }
    }
  }
}
</script>

<style lang="scss">
</style>
