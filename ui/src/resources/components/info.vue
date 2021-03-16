<template>
  <div
    class="bg-white"
    :style="{ position: 'relative' }"
  >
    <Spin
      v-if="isLoading || isReloading"
      fix
    />
    <div
      v-if="!isLoading"
      class="row"
    >
      <div
        class="pe-4"
        :class="withActions ? 'col-11' : 'col-12'"
      >
        <div
          class="row"
          :style="oneColumn ? 'max-width: 500px' : ''"
        >
          <template
            v-for="column in columns"
            :key="column.name"
          >
            <div
              v-if="![null, undefined, ''].includes(resource[column.name])"
              :class="oneColumn ? 'col-12' : 'col-xxl-3 col-xl-6 col-md-12 col-12'"
              class="mb-3"
            >
              <h2 v-if="column.name === 'id'">
                {{ titleize(model.name) }} #{{ resource.id }}
              </h2>
              <template v-else>
                <b>
                  {{ column.display_name }}:
                </b>
                <br>
                <Reference
                  v-if="column.reference"
                  :resource-id="resource[column.name]"
                  :reference-name="column.reference.model_name"
                  :show-popover="referencePopover"
                  :reference-data="resource[column.reference.name]"
                  :polymorphic-name="resource[column.reference.name + '_type']"
                />
                <DataCell
                  v-else
                  :value="resource[column.name]"
                  :text-truncate="false"
                  :type="columnType(column)"
                />
              </template>
            </div>
          </template>
        </div>
      </div>
      <div
        v-if="withActions"
        class="col-1 d-flex justify-content-end"
      >
        <ResourceActions
          :resources="[resource]"
          :resource-name="model.name"
          :button-type="'primary'"
          :button-ghost="false"
          :label="'Actions'"
          @start-action="isReloading = true"
          @finish-action="onFinisAction"
        />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from 'utils/scripts/schema'

import DataCell from 'data_cells/components/data_cell'
import Reference from 'data_cells/components/reference'
import ResourceActions from './actions'

import { assignBreadcrumbLabel } from 'navigation/scripts/breadcrumb_store'
import { titleize, truncate } from 'utils/scripts/string'

import DataTypes from 'data_cells/scripts/data_types'

export default {
  name: 'ResourceInfo',
  components: {
    DataCell,
    Reference,
    ResourceActions
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    },
    withActions: {
      type: Boolean,
      required: false,
      default: false
    },
    oneColumn: {
      type: Boolean,
      required: false,
      default: true
    },
    referencePopover: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['remove'],
  data () {
    return {
      resource: {},
      isLoading: true,
      isReloading: true
    }
  },
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    },
    columns () {
      return this.model.columns
    },
    includeParams () {
      return this.columns.map((column) => {
        return column.reference?.name
      }).filter(Boolean).join(',')
    },
    queryParams () {
      const params = {
      }

      if (this.includeParams) {
        params.include = this.includeParams
      }

      return params
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    titleize,
    onFinisAction (action) {
      if (action === 'remove') {
        this.$emit('remove', this.resource)
      } else {
        this.loadData()
      }
    },
    columnType (column) {
      return column.validators.find((v) => v.includes?.length) ? DataTypes.TAG : column.column_type
    },
    loadData () {
      this.isReoading = true

      api.get(`data/${this.model.slug}/${this.resourceId}`, {
        params: this.queryParams
      }).then((result) => {
        this.resource = result.data.data

        if (this.model.display_column && this.resource[this.model.display_column]) {
          assignBreadcrumbLabel(
            this.resourceName,
            this.resourceId,
            `#${this.resourceId} ${truncate(this.resource[this.model.display_column], 22)}`
          )
        }
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
        this.isReloading = false
      })
    }
  }
}
</script>
