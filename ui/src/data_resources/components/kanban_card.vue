<template>
  <div class="ivu-card ivu-card-bordered">
    <div
      class="ivu-card-head d-flex justify-content-between align-items-center"
      style="padding: 2px 0 2px 12px"
    >
      <b
        v-if="model.display_primary_key"
        class="cursor-pointer"
        @click="onItemClick"
      >
        {{ title }}
      </b>
      <InfoCell
        v-else
        ref="infoCell"
        :resource="resource"
        :is-kanban="true"
        :column="displayColumn"
        :resource-name="resourceName"
        :editable="$can('edit', model.class_name, resource)"
        :reference-popover="referencePopover"
        class="fw-bold mb-0 cursor-pointer"
        @click="maybeGoToPage"
        @update="$emit('update', $event)"
      />
      <ResourceActions
        :resources="[resource]"
        :resource-name="model.name"
        :button-type="'text'"
        :button-ghost="false"
        :button-icon="'md-more'"
        :label="''"
        :with-buttons="false"
        :placement="'bottom-end'"
        @start-action="$emit('start-action', $event)"
        @finish-action="$emit('finish-action', $event)"
      />
    </div>
    <div
      class="ivu-card-body"
      style="padding: 4px 12px"
    >
      <div class="row">
        <template
          v-for="column in columns"
          :key="column.name"
        >
          <div
            :class="'col-12'"
            class="my-1"
          >
            <b>
              {{ column.display_name }}:
            </b>
            <br>
            <InfoCell
              :resource="resource"
              :column="column"
              :resource-name="resourceName"
              :is-kanban="true"
              :editable="$can('edit', model.class_name, resource)"
              :reference-popover="referencePopover"
              @update="$emit('update', $event)"
            />
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import InfoCell from './info_cell'
import { modelNameMap } from '../scripts/schema'
import ResourceActions from './actions'
import singularize from 'inflected/src/singularize'

export default {
  name: 'ResourceInfo',
  components: {
    InfoCell,
    ResourceActions
  },
  props: {
    resource: {
      type: Object,
      required: true
    },
    resourceName: {
      type: String,
      required: true
    },
    displayColumns: {
      type: Array,
      require: false,
      default: () => []
    },
    referencePopover: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['update', 'start-action', 'finish-action'],
  computed: {
    displayColumn () {
      return this.model.columns.find((column) => column.name === this.model.display_column)
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    title () {
      const primaryKeyValue = this.resource[this.model.primary_key]
      const isNumber = primaryKeyValue?.toString()?.match(/^\d+$/)

      return `${singularize(this.model.display_name)}${isNumber ? ' #' : ': '}${primaryKeyValue}`
    },
    columns () {
      if (this.displayColumns?.length) {
        return this.displayColumns.map((columnName) => {
          return this.model.columns.find((column) => column.name === columnName)
        }).filter(Boolean)
      } else {
        return this.model.columns.filter((column) => {
          return column.name !== 'id' &&
          (this.model.display_primary_key || column.name !== this.displayColumn.name) &&
          ['read_only', 'read_write'].includes(column.access_type)
        }).slice(0, 4)
      }
    }
  },
  methods: {
    maybeGoToPage (e) {
      if (this.$refs.infoCell.$refs.dataCell.$el === e.target) {
        this.onItemClick()
      }
    },
    onItemClick () {
      if (this.model.primary_key) {
        this.$router.push({
          name: 'resources',
          params: {
            fragments: [...this.$route.params.fragments, this.resource[this.model.primary_key]]
          }
        })
      }
    }
  }
}
</script>
