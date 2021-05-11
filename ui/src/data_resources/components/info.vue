<template>
  <div
    :style="{ position: 'relative' }"
  >
    <Spin
      v-if="isLoading || isReloading"
      fix
    />
    <div
      v-if="!isLoading"
    >
      <div
        class="d-flex"
      >
        <div
          style="min-width: 250px"
          :style="withActions && !notFound ? 'width: calc(100% - 100px)' : 'width: 100%'"
        >
          <p
            v-if="notFound"
            class="text-center mt-2"
          >
            Not Found
          </p>
          <h2
            v-else
            class="mb-3"
          >
            {{ title }}
          </h2>
        </div>
        <div
          v-if="withActions && !notFound"
          class="d-flex justify-content-end"
          style="width: 100px"
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
      <div
        class="row"
        :style="oneColumn && !notFound ? 'max-width: 500px' : ''"
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
            <b>
              {{ column.display_name }}:
            </b>
            <br>
            <DataCell
              v-if="column.reference?.model_name === 'active_storage/attachment'"
              :value="resource[column.name]?.path"
              :type="'string'"
            />
            <Reference
              v-else-if="column.reference"
              :resource-id="getReferenceId(column)"
              :reference-name="column.reference.model_name"
              :max-length="oneColumn ? 30 : 20"
              :show-popover="referencePopover"
              :reference-data="resource[column.reference.name]"
              :polymorphic-name="resource[column.reference.name + '_type']"
            />
            <DataCell
              v-else
              :value="resource[column.name]"
              :format="column.format"
              :text-truncate="false"
              :type="columnType(column)"
            />
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import singularize from 'inflected/src/singularize'

import DataCell from 'data_cells/components/data_cell'
import Reference from 'data_cells/components/reference'
import ResourceActions from './actions'

import { assignBreadcrumbLabel } from 'navigation/scripts/breadcrumb_store'
import { truncate } from 'utils/scripts/string'
import { includeParams, fieldsParams } from '../scripts/query_utils'

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
      notFound: false,
      isLoading: true,
      isReloading: true
    }
  },
  computed: {
    title () {
      return `${singularize(this.model.display_name)} #${this.resource[this.model.primary_key]}`
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
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    getReferenceId (column) {
      if (column.reference.reference_type === 'belongs_to') {
        return this.resource[column.name]
      } else {
        const referenceModel = modelNameMap[column.reference.model_name]

        return this.resource[column.name][referenceModel.primary_key]
      }
    },
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
      this.isReloading = true

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
        if (error.response.status === 404) {
          this.notFound = true
        } else {
          console.error(error)
        }
      }).finally(() => {
        this.isLoading = false
        this.isReloading = false
      })
    }
  }
}
</script>
