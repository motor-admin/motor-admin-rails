<template>
  <div
    class="bg-white"
    :style="{ position: 'relative' }"
  >
    <Spin
      v-if="isLoading"
      fix
    />
    <div
      v-else
      class="row"
      :style="oneColumn ? 'max-width: 500px' : ''"
    >
      <template
        v-for="column in columns"
        :key="column.name"
      >
        <div
          v-if="resource[column.name]"
          :class="oneColumn ? 'col-12' : 'col-xxl-3 col-xl-6 col-md-12 col-12'"
          class="mb-3"
        >
          <b>
            {{ column.display_name }}:
          </b>
          <br>
          <Reference
            v-if="column.reference"
            :resource-id="resource[column.name]"
            :reference-name="column.reference.name"
            :show-popover="referencePopover"
            :reference-data="resource[column.reference.name]"
            :polymorphic-name="resource[column.reference.polymorphic_key]"
          />
          <DataCell
            v-else
            :value="resource[column.name]"
            :text-truncate="false"
            :type="columnType(column)"
          />
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import api from 'api'
import store from 'store'

import DataCell from 'data_cells/components/data_cell'
import Reference from 'data_cells/components/reference'

import DataTypes from 'data_cells/scripts/data_types'

export default {
  name: 'ResourceInfo',
  components: {
    DataCell,
    Reference
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
  data () {
    return {
      resource: {},
      isLoading: true
    }
  },
  computed: {
    schema () {
      return store.getters.slugsMap[this.resourceName]
    },
    columns () {
      return this.schema.columns
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
    columnType (column) {
      return column.validators.find((v) => v.includes?.length) ? DataTypes.TAG : column.column_type
    },
    loadData () {
      this.isLoading = true

      api.get(`data/${this.resourceName}/${this.resourceId}`, {
        params: this.queryParams
      }).then((result) => {
        this.resource = result.data.data
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
