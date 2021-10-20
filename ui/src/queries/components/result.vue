<template>
  <div
    v-if="errors.length"

    class="d-flex justify-content-center align-items-center text-danger text-center"
    :style="{ height: 'calc(100% - 34px)' }"
  >
    <p
      v-for="error in errors"
      :key="error.detail || error"
    >
      {{ error.detail || error }}
    </p>
  </div>
  <ValueResult
    v-else-if="isValue"
    :style="{ height: (withFooter && showFooter) || !data.length ? 'calc(100% - 34px)' : '100%' }"
    :loading="loading"
    :data="paginatedData"
  />
  <div
    v-else-if="isTable || isMarkdown || isTableToggle"
    class="d-flex"
    :style="{ height: withFooter ? 'calc(100% - 34px)' : '100%' }"
  >
    <div
      v-if="isMarkdown"
      :style="{ width: showMarkdownTable ? '50%' : '100%' }"
      class="bg-white"
    >
      <Markdown
        :style="{ height: '100%', overflow: 'scroll', padding: '10px 13px' }"
        :class="{ 'border-right': showMarkdownTable }"
        :loading="loading"
        :markdown="preferences.visualization_options.markdown"
        :data="markdownData"
      />
    </div>
    <div
      v-if="isTable || isTableToggle || showMarkdownTable"
      :style="{ width: isTable || isTableToggle ? '100%' : '50%' }"
    >
      <DataTable
        :data="paginatedData"
        :with-select="false"
        :click-rows="false"
        :borderless="borderless"
        :always-refer="true"
        :header-border="headerBorder"
        :compact="compact"
        :columns="normalizedColumns"
        @sort-change="assignSortParams"
      />
    </div>
  </div>
  <div
    v-else
    :style="{ height: 'calc(100% - 34px)' }"
  >
    <Chart
      ref="chart"
      :data="data"
      :loading="loading"
      :options="preferences.visualization_options"
      :columns="normalizedColumns"
      :chart-type="chartType"
    />
  </div>
  <div
    v-if="withFooter && showFooter"
    class="d-flex justify-content-center text-center border-top bg-white p-1"
  >
    <div
      class="d-flex justify-content-start"
      style="width: 15%"
    >
      <VButton
        v-if="withSettings"
        icon="md-settings"
        size="small"
        class="md-icon-only"
        style="height: 24px"
        @click="$emit('settings')"
      >
        {{ i18n['settings'] }}
      </VButton>
    </div>
    <div
      :style="{ width: '70%', whiteSpace: 'nowrap' }"
    >
      <Pagination
        v-if="showPagination"
        :current="paginationParams.current"
        :total="total"
        :page-size="pageSize"
        :page-size-opts="pageSizeOpts"
        size="small"
        :show-sizer="!minimalPagination && !isMarkdown && !isValue"
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
        v-if="withTableToggle && !isMarkdown && !isTable && !isValue"
        :icon="isTableToggle ? 'md-analytics' : 'md-grid'"
        type="text"
        size="small"
        style="height: 24px"
        @click="toggleTable"
      />
      <VButton
        v-if="withAlert"
        icon="md-notifications"
        type="text"
        size="small"
        style="height: 24px"
        @click="$router.push({ name: 'new_alert', query: { query_id: queryId } })"
      />
      <VButton
        v-if="!!data.length"
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
import Markdown from 'utils/components/markdown'
import ValueResult from './value'
import { modelNameMap } from 'data_resources/scripts/schema'
import csv from 'view3/src/utils/csv'
import { underscore } from 'utils/scripts/string'
import { formatDate } from 'utils/scripts/date_format'

export default {
  name: 'QueryTable',
  components: {
    DataTable,
    Chart,
    Markdown,
    ValueResult
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
    withTableToggle: {
      type: Boolean,
      required: false,
      default: false
    },
    withAlert: {
      type: Boolean,
      required: false,
      default: false
    },
    showMarkdownTable: {
      type: Boolean,
      required: false,
      default: false
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
    },
    borderless: {
      type: Boolean,
      required: false,
      default: false
    },
    headerBorder: {
      type: Boolean,
      required: false,
      default: true
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
    withFooter: {
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
      hSplit: 0.5,
      isTableToggle: false,
      paginationParams: {
        current: 1,
        pageSize: this.defaultPageSize
      }
    }
  },
  computed: {
    showFooter () {
      return !!this.data.length && (!this.isValue || this.withSettings || this.withAlert || this.showPagination)
    },
    showPagination () {
      return (this.data.length && this.isTable) || ((this.isMarkdown || this.isValue) && this.data.length > 1)
    },
    markdownData () {
      if (this.data.length) {
        return this.columns.reduce((acc, column, index) => {
          if (['datetime', 'date'].includes(column.column_type)) {
            acc[column.name] = formatDate(this.paginatedData[0][index], null, column.column_type === 'datetime')
          } else if (column.column_type === 'json') {
            acc[column.name] = JSON.parse(this.paginatedData[0][index])
          } else {
            acc[column.name] = this.paginatedData[0][index]
          }

          return acc
        }, {})
      } else {
        return {}
      }
    },
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
    isMarkdown () {
      return this.preferences.visualization === 'markdown'
    },
    isValue () {
      return this.preferences.visualization === 'value'
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
    pageSize () {
      return (this.isMarkdown || this.isValue) ? 1 : this.paginationParams.pageSize
    },
    paginatedData () {
      const fromIndex = (this.paginationParams.current - 1) * this.pageSize

      return this.sortedData.slice(fromIndex, fromIndex + this.pageSize)
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
  watch: {
    defaultPageSize (value) {
      this.paginationParams.pageSize = value
    },
    data () {
      this.paginationParams.current = 1
    }
  },
  methods: {
    assignSortParams (params) {
      this.sortParams = params
    },
    toggleTable () {
      this.isTableToggle = !this.isTableToggle
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
        const csvData = csv(this.normalizedColumns, this.sortedData, { quoted: true })

        dataUrl = URL.createObjectURL(new Blob([csvData], { type: 'data:text/csv;charset=utf-8' }))
      }

      const link = document.createElement('a')

      link.setAttribute('href', dataUrl)
      link.setAttribute('download', `${underscore(this.title || 'query')}_${underscore(dateTime)}.${fileType}`)

      link.click()
    }
  }
}
</script>
