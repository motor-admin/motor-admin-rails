<template>
  <div
    class="h-100"
    :style="{ position: 'relative' }"
  >
    <div
      class="d-flex flex-column h-100"
    >
      <div
        class="d-flex h-100"
      >
        <div
          class="position-relative h-100"
          style="min-width: 250px; width: calc(100% - 100px)"
        >
          <QueryTab
            ref="query"
            class="richtext-no-padding richtext-no-scroll"
            :tab="detailsTab"
            :variables="queryVariables"
          />
          <SettingsMask
            v-if="isShowSettings && detailsTab.tab_type === 'query'"
            :settings-type="detailsTab.tab_type"
            :preferences="detailsTab.preferences"
          />
        </div>
        <div
          v-if="!notFound"
          class="d-flex justify-content-end"
          style="width: 100px"
        >
          <SettingsMask
            v-if="isShowSettings"
            :button-only="true"
            :settings-type="'actions'"
            :resource="model"
          />
          <ResourceActions
            v-else
            :resources="[resource]"
            :resource-name="model.name"
            :button-type="'primary'"
            :button-ghost="false"
            :label="i18n['actions']"
            @finish-action="onFinisAction"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'

import ResourceActions from './actions'
import QueryTab from './query_tab'

import { assignBreadcrumbLabel } from 'navigation/scripts/breadcrumb_store'
import { includeParams, fieldsParams } from '../scripts/query_utils'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'

export default {
  name: 'ResourceInfo',
  components: {
    ResourceActions,
    SettingsMask,
    QueryTab
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    }
  },
  emits: ['remove'],
  data () {
    return {
      resource: {},
      notFound: false
    }
  },
  computed: {
    isShowSettings,
    detailsTab () {
      return this.model.tabs.find((t) => t.name === 'details')
    },
    queryVariables () {
      return {
        [`${this.resourceName}_id`]: this.resourceId,
        ...this.resource
      }
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    columns () {
      return this.model.columns.filter((column) => column.name !== 'id' && ['read_only', 'read_write'].includes(column.access_type))
    },
    includeParams () {
      return includeParams(this.model)
    },
    fieldsParams () {
      return fieldsParams(this.model)
    },
    queryParams () {
      const params = {
        fields: this.fieldsParams
      }

      if (this.includeParams) {
        params.include = this.includeParams
      }

      return params
    }
  },
  watch: {
    columns: {
      deep: true,
      handler (newValue, oldValue) {
        if (newValue.length > oldValue.length) {
          this.loadData()
        }
      }
    },
    'model.display_column' () {
      this.assignBreadcrumbLabel()
    },
    'model.display_primary_key' () {
      this.assignBreadcrumbLabel()
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    onFinisAction (action) {
      if (action === 'remove') {
        this.$emit('remove', this.resource)
      } else {
        this.loadData()
        this.$refs.query.runQuery()
      }
    },
    assignResource (data) {
      this.resource = data

      this.assignBreadcrumbLabel()
    },
    assignBreadcrumbLabel () {
      const labelParts = this.model.display_primary_key ? [`${this.resourceId.toString().match(/^\d+$/) ? '#' : ''}${this.resourceId}`] : []

      if (this.model.display_column && this.resource[this.model.display_column] && this.resourceId.toString() !== this.resource[this.model.display_column].toString()) {
        labelParts.push(`${this.resource[this.model.display_column]}`)
      }

      assignBreadcrumbLabel(this.resourceName, this.resourceId, labelParts.join(' '))
    },
    loadData () {
      api.get(`data/${this.model.slug}/${this.resourceId}`, {
        params: this.queryParams
      }).then((result) => {
        this.assignResource(result.data.data)
      }).catch((error) => {
        if (error.response?.status === 404) {
          this.notFound = true
        } else {
          console.error(error)

          if (error.response?.data?.errors) {
            this.$Message.error(error.response.data.errors.join('\n'))
          } else {
            this.$Message.error(error.message)
          }
        }
      })
    }
  }
}
</script>
