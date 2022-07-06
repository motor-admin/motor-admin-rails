<template>
  <canvas
    v-if="data.length"
    ref="canvas"
    class="bg-white p-2"
  />
  <div
    v-else-if="!loading"
    class="d-flex justify-content-center align-items-center"
    style="height: 100%"
  >
    {{ i18n['no_data'] }}
  </div>
</template>

<script>
import {
  Chart,
  LineController,
  LineElement,
  PointElement,
  LinearScale,
  RadialLinearScale,
  BarElement,
  BarController,
  CategoryScale,
  PieController,
  RadarController,
  ArcElement,
  Legend,
  Tooltip,
  Filler
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
  RadarController,
  RadialLinearScale,
  CategoryScale,
  PieController,
  ArcElement,
  Legend,
  Tooltip,
  ChartDataLabels,
  Filler
)

const backgroundColors = [
  'rgb(64, 131, 207, 0.8)',
  'rgba(255, 99, 132, 0.8)',
  'rgba(255, 206, 86, 0.8)',
  'rgba(54, 162, 235, 0.8)',
  'rgba(75, 192, 192, 0.8)',
  'rgba(153, 102, 255, 0.8)',
  'rgba(255, 159, 64, 0.8)'
]

const borderColors = [
  'rgb(64, 131, 207, 1)',
  'rgba(255, 99, 132, 1)',
  'rgba(255, 206, 86, 1)',
  'rgba(54, 162, 235, 1)',
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
    options: {
      type: Object,
      required: false,
      default: () => ({})
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
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
    labelsFormat () {
      return {
        style: this.options.label_format || 'decimal',
        options: this.options.label_format_options || {}
      }
    },
    chartTypeOption () {
      return {
        funnel: 'line',
        row: 'bar'
      }[this.chartType] || this.chartType
    },
    transposedData () {
      return this.data[0].map((col, i) => this.data.map(([...row]) => row[i]))
    },
    datasets () {
      return this.transposedData.slice(1, this.transposedData.length).map((data, index) => {
        if (['integer', 'float'].includes(this.columns[index + 1].type)) {
          return {
            fill: this.chartType === 'funnel',
            label: this.columns[index + 1].title,
            backgroundColor: this.chartType === 'pie' ? backgroundColors : backgroundColors[index],
            borderColor: this.chartType === 'pie' ? '#fff' : borderColors[index],
            borderWidth: ['bar', 'row'].includes(this.chartType) ? 0 : 2,
            data
          }
        } else {
          return null
        }
      }).filter(Boolean)
    },
    chartParams () {
      return {
        type: this.chartTypeOption,
        data: {
          labels: this.labels,
          datasets: this.datasets
        },
        options: this.chartOptions
      }
    },
    chartOptions () {
      const options = {
        responsive: true,
        maintainAspectRatio: false,
        indexAxis: this.chartType === 'row' ? 'y' : 'x',
        animation: false,
        plugins: {
          legend: {
            labels: {
              usePointStyle: true
            }
          },
          tooltip: {
            callbacks: {
              label: (context) => {
                let label = context.dataset.label || ''
                const key = this.chartType === 'row' ? 'x' : (this.chartType === 'radar' ? 'r' : 'y')

                if (label) {
                  label += ': '
                }

                if (context.parsed[key] !== null) {
                  const value = this.formatValue(context.parsed[key] || context.parsed)

                  if (this.chartType === 'pie') {
                    label = context.label + ': ' + value
                  } else {
                    label += value
                  }
                }

                return label
              }
            }
          }
        },
        scales: {
          x: {
            display: this.chartType !== 'pie',
            stacked: this.options.chart_stacked,
            grid: {
              display: false
            }
          },
          y: {
            stacked: this.options.chart_stacked,
            display: this.options.chart_values_axis || this.chartType === 'row',
            grid: {
              display: false
            },
            ticks: {
              callback: (value) => {
                return this.formatValue(value)
              }
            }
          }
        }
      }

      if (this.chartType !== 'pie' && this.datasets.length === 1) {
        options.plugins = deepmerge(options.plugins, {
          legend: {
            display: false
          }
        })
      }

      if (this.chartType === 'pie') {
        options.radius = '85%'
        options.plugins = deepmerge(options.plugins, {
          legend: {
            position: 'left'
          }
        })
        options.scales.y = { display: false }
      }

      if (this.chartType !== 'pie') {
        options.scales = deepmerge(options.scales, {
          x: {
            grid: {
              display: false
            }
          }
        })
      }

      if (this.chartType === 'funnel') {
        options.scales = deepmerge(options.scales, {
          y: {
            beginAtZero: true,
            grid: {
              display: false
            }
          }
        })
      }

      options.plugins = deepmerge(options.plugins, {
        datalabels: {
          labels: {
            value: {
              display: ['bar', 'row'].includes(this.chartType) ? true : (this.chartType === 'radar' ? false : 'auto'),
              anchor: this.options.chart_stacked ? 'center' : 'end',
              align: this.options.chart_stacked && this.chartType !== 'line' ? 'center' : (['pie', 'row'].includes(this.chartType) ? 'end' : 'top'),
              formatter: (value) => {
                return this.formatValue(value)
              },
              font: {
                weight: 'bold'
              }
            }
          }
        }
      })

      if (this.options.chart_stacked && ['bar', 'row'].includes(this.chartType)) {
        options.plugins = deepmerge(options.plugins, {
          datalabels: {
            labels: {
              data: {
                align: 'end',
                anchor: 'end',
                color: (ctx) => {
                  if (ctx.datasetIndex !== this.datasets.length - 1) {
                    return 'transparent'
                  }
                },
                formatter: (value, ctx) => {
                  const sum = this.datasets.map((d) => d.data[ctx.dataIndex]).reduce((acc, val) => acc + val, 0)
                  return [this.i18n.total, this.formatValue(sum)].join(': ')
                },
                font: {
                  weight: 'bold'
                }
              }
            }
          }
        })
      }

      if (this.chartType === 'pie') {
        options.plugins = deepmerge(options.plugins, {
          datalabels: {
            display: 'auto',
            formatter (value, context) {
              const sum = context.dataset.data.reduce((acc, val) => acc + parseFloat(val), 0)

              return Math.round(value * 10000 / sum, 2) / 100 + '%'
            }
          }
        })
      }

      if (this.chartType === 'funnel') {
        options.plugins = deepmerge(options.plugins, {
          datalabels: {
            display: 'auto',
            align: 'end',
            formatter (value, context) {
              if (context.dataIndex !== 0) {
                const base = context.dataset.data[0]

                return Math.round(value * 10000 / base, 2) / 100 + '%'
              } else {
                return ' '
              }
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
      if (['line', 'row', 'funnel'].includes(this.chartType)) {
        options.layout = deepmerge(options.layout, {
          padding: {
            right: 25
          }
        })
      }

      if (['row'].includes(this.chartType)) {
        options.layout = deepmerge(options.layout, {
          padding: {
            right: 55
          }
        })
      }

      if (this.chartType === 'row') {
        options.scales = {
          x: {
            stacked: this.options.chart_stacked,
            display: this.options.chart_values_axis,
            grid: { display: false },
            ticks: {
              callback: (value) => {
                return this.formatValue(value)
              }
            }
          },
          y: {
            stacked: this.options.chart_stacked,
            grid: { display: false }
          }
        }
      }

      return options
    },
    labels () {
      const labelColumn = this.columns[0]
      const labels = this.transposedData[0]

      if (['date', 'datetime'].includes(labelColumn.type)) {
        const formatOptions = { year: 'numeric', month: 'short' }

        if (!labels.every((string) => string.includes('-01T00:00:00') || string.match(/-01$/))) {
          formatOptions.day = 'numeric'
        }

        return labels.map((label) => formatDate(label, formatOptions))
      } else {
        return labels
      }
    }
  },
  watch: {
    chartType () {
      this.update()
    },
    options: {
      deep: true,
      handler () {
        this.update()
      }
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
      this.render()
    },
    formatValue (value) {
      return new Intl.NumberFormat(navigator.language || 'en-US', { style: this.labelsFormat?.style || 'decimal', ...(this.labelsFormat?.options || {}) }).format(value)
    },
    render () {
      if (this.data.length) {
        this.$nextTick(() => {
          this.chart?.destroy()
          this.chart = new Chart(this.$refs.canvas.getContext('2d'), this.chartParams)
        })
      }
    }
  }
}
</script>

<style lang="scss">
</style>
