<template>
  <div
    v-if="errors.length"

    class="d-flex justify-content-center align-items-center text-danger text-center"
    :style="{ height: 'calc(100% - 34px)' }"
  >
    <p
      v-for="error in errors"
      :key="error.detail"
    >
      {{ error.detail }}
    </p>
  </div>
  <DataTable
    v-else-if="isTable"
    :style="{ height: 'calc(100% - 34px)' }"
    :data="paginatedData"
    :with-select="false"
    :click-rows="false"
    :borderless="borderless"
    :compact="compact"
    :columns="normalizedColumns"
    @sort-change="assignSortParams"
  />
  <div
    v-else
    :style="{ height: 'calc(100% - 34px)' }"
  >
    <Chart
      v-if="data.length"
      ref="chart"
      :data="data"
      :labels-format="preferences.format"
      :columns="normalizedColumns"
      :chart-type="chartType"
    />
  </div>
  <div class="d-flex justify-content-center text-center border-top bg-white p-1">
    <div
      class="d-flex justify-content-start"
      style="width: 15%"
    >
      <VButton
        v-if="withSettings"
        icon="md-settings"
        size="small"
        style="height: 24px"
        @click="$emit('settings')"
      >
        Settings
      </VButton>
    </div>
    <div
      :style="{ width: '70%' }"
    >
      <Pagination
        v-if="data.length && isTable"
        :current="paginationParams.current"
        :total="total"
        :page-size="paginationParams.pageSize"
        :page-size-opts="pageSizeOpts"
        size="small"
        :show-sizer="!minimalPagination"
        :show-elevator="!minimalPagination"
        :show-total="true"
        @update:current="paginationParams.current = $event"
        @update:page-size="paginationParams.pageSize = $event"
      />
    </div>
    <div
      class="d-flex justify-content-end"
      style="width: 15%"
    >
      <VButton
        v-if="withAlert"
        icon="md-notifications"
        type="text"
        size="small"
        style="height: 24px"
        @click="$router.push({ name: 'new_alert', query: { query_id: queryId } })"
      />
      <VButton
        icon="md-download"
        type="text"
        size="small"
        style="height: 24px"
        @click="download"
      />
    </div>
  </div>
</template>

<script>
import DataTable from 'data_tables/components/table'
import Chart from './chart'
import { modelNameMap } from 'utils/scripts/schema'
import csv from 'view3/src/utils/csv'
import { underscore } from 'utils/scripts/string'
import { formatDate } from 'utils/scripts/date_format'

export default {
  name: 'QueryTable',
  components: {
    DataTable,
    Chart
  },
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
    errors: {
      type: Array,
      required: false,
      default: () => []
    },
    title: {
      type: String,
      required: false,
      default: ''
    },
    preferences: {
      type: Object,
      required: false,
      default () {
        return {}
      }
    },
    queryId: {
      type: [Number, String],
      required: false,
      default: ''
    },
    withAlert: {
      type: Boolean,
      required: false,
      default: false
    },
    borderless: {
      type: Boolean,
      required: false,
      default: false
    },
    compact: {
      type: Boolean,
      required: false,
      default: false
    },
    withSettings: {
      type: Boolean,
      required: false,
      default: true
    },
    defaultPageSize: {
      type: Number,
      required: false,
      default: 100
    },
    minimalPagination: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['settings'],
  data () {
    return {
      sortParams: {},
      paginationParams: {
        current: 1,
        pageSize: this.defaultPageSize
      }
    }
  },
  computed: {
    sortedData () {
      const { key, order } = this.sortParams
      const orderMultiplier = order === 'desc' ? -1 : 1

      if (order) {
        return [...this.data].sort((a, b) => (a[key] > b[key] ? 1 : -1) * orderMultiplier)
      } else {
        return this.data
      }
    },
    total () {
      return this.data.length
    },
    isTable () {
      return !this.preferences.visualization || this.preferences.visualization === 'table'
    },
    pageSizeOpts () {
      return [20, 50, 100, 250, 500, 1000]
    },
    chartType () {
      if (this.isTable) {
        return ''
      } else {
        return this.preferences.visualization.replace(/_chart$/, '')
      }
    },
    paginatedData () {
      const fromIndex = (this.paginationParams.current - 1) * this.paginationParams.pageSize

      return this.sortedData.slice(fromIndex, fromIndex + this.paginationParams.pageSize)
    },
    normalizedColumns () {
      return this.columns.map((column, index) => {
        let reference
        const [, modelName] = column.name.match(/^(\w+)_id$/) || []

        if (modelName && modelNameMap[modelName]) {
          reference = { model_name: modelName }
        }

        return {
          key: index,
          title: column.name,
          type: column.column_type,
          reference
        }
      })
    }
  },
  methods: {
    assignSortParams (params) {
      this.sortParams = params
    },
    download () {
      const fileType = this.$refs.chart ? 'png' : 'csv'
      const dateTime = formatDate(new Date(), {
        year: 'numeric',
        month: 'numeric',
        day: 'numeric',
        hour: 'numeric',
        minute: 'numeric',
        hour12: true
      }).replace(',', '')

      let dataUrl = ''

      if (this.$refs.chart) {
        dataUrl = this.$refs.chart.chart.toBase64Image()
      } else {
        dataUrl = 'data:text/csv;charset=utf-8,' + csv(this.normalizedColumns, this.sortedData, { quoted: true })
      }

      const encodedUri = encodeURI(dataUrl)
      const link = document.createElement('a')

      link.setAttribute('href', encodedUri)
      link.setAttribute('download', `${underscore(this.title || 'query')}_${underscore(dateTime)}.${fileType}`)

      link.click()
    }
  }
}
</script>
