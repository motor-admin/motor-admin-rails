<template>
  <div class="row">
    <div class="col-5 pe-2 ps-0">
      <MSelect
        v-model="dataFilter.key"
        filterable
        style="margin-left: 50px; width: calc(100% - 50px)"
        :options="columns"
        @update:modelValue="onKeyChange"
      />
      <slot />
    </div>
    <div class="col-2 p-0">
      <MSelect
        v-model="dataFilter.action"
        :options="actions"
      />
    </div>
    <div class="d-flex col-5 ps-2 pe-0">
      <FormInput
        v-if="selectedColumn && !['contains', 'starts_with', 'ends_with'].includes(dataFilter.action)"
        v-model="dataFilter.value"
        :column="selectedColumn"
      />
      <VInput
        v-else
        v-model="dataFilter.value"
      />
      <VButton
        icon="md-close"
        class="ms-1"
        type="text"
        @click="$emit('remove', filter)"
      />
    </div>
  </div>
</template>

<script>
import FormInput from 'data_forms/components/input'
import { modelNameMap } from '../scripts/schema'

const ACTIONS = ['eq', 'neq', 'contains', 'gt', 'gte', 'lt', 'lte', 'starts_with', 'ends_with']

export default {
  name: 'FilterItem',
  components: {
    FormInput
  },
  props: {
    filter: {
      type: Object,
      required: true
    },
    model: {
      type: Object,
      required: true
    }
  },
  emits: ['remove', 'update:filter'],
  data () {
    return {
      dataFilter: {
        key: '',
        action: 'eq',
        value: ''
      }
    }
  },
  computed: {
    selectedColumn () {
      return this.columns.find((column) => column.value === this.dataFilter.key)
    },
    columns () {
      return [
        ...this.model.columns.map((column) => {
          if (!column.virtual && !column.reference && ['read_write', 'read_only'].includes(column.access_type)) {
            return {
              ...column,
              value: column.name,
              label: column.display_name
            }
          } else {
            return null
          }
        }).filter(Boolean),
        ...this.model.columns.map((column) => {
          if (column.reference && ['read_write', 'read_only'].includes(column.access_type)) {
            const referenceModel = modelNameMap[column.reference.model_name]

            return referenceModel.columns.map((refColumn) => {
              if (!refColumn.virtual && ['read_write', 'read_only'].includes(refColumn.access_type)) {
                return {
                  ...refColumn,
                  value: `${column.name}.${refColumn.name}`,
                  label: `${column.display_name} - ${refColumn.display_name}`
                }
              } else {
                return null
              }
            }).filter(Boolean)
          } else {
            return []
          }
        }).flat(),
        ...this.model.associations.map((assoc) => {
          if (assoc.visible) {
            const assocModel = modelNameMap[assoc.model_name]

            return assocModel.columns.map((column) => {
              if (!column.virtual && ['read_write', 'read_only'].includes(column.access_type)) {
                return {
                  ...column,
                  value: `${assoc.name}.${column.name}`,
                  label: `${assoc.display_name} - ${column.display_name}`
                }
              } else {
                return null
              }
            }).filter(Boolean)
          } else {
            return []
          }
        }).flat()
      ]
    },
    actions () {
      const actions = [
        { value: 'eq', label: 'is' },
        { value: 'neq', label: 'is not' }
      ]

      if (!this.selectedColumn) {
        return actions
      }

      if (this.selectedColumn.column_type === 'string') {
        actions.push(
          { value: 'contains', label: 'contains' },
          { value: 'starts_with', label: 'starts with' },
          { value: 'ends_with', label: 'ends with' }
        )
      } else if (['integer', 'float', 'date', 'datetime'].includes(this.selectedColumn.column_type)) {
        actions.push(
          { value: 'gt', label: 'greater than' },
          { value: 'gte', label: 'greater or equal' },
          { value: 'lt', label: 'less than' },
          { value: 'lte', label: 'less or equal' }
        )
      }

      return actions
    }
  },
  watch: {
    dataFilter: {
      deep: true,
      handler ({ key, value, action }) {
        const [assoc, assocColumn] = key.split('.')

        if (assocColumn) {
          this.$emit('update:filter', { [assoc]: { [assocColumn]: { [action]: value } } })
        } else {
          this.$emit('update:filter', { [key]: { [action]: value } })
        }
      }
    }
  },
  mounted () {
    this.assignDataFilter()
  },
  methods: {
    assignDataFilter () {
      const [[key, actionObject]] = Object.entries(this.filter)
      const [[action, value]] = Object.entries(actionObject)

      if (ACTIONS.includes(action)) {
        this.dataFilter = { key, action, value }
      } else {
        const [[assocAction, assocValue]] = Object.entries(value)

        this.dataFilter = { key: `${key}.${action}`, action: assocAction, value: assocValue }
      }
    },
    onKeyChange (key) {
      if (!this.actions.find((action) => action.value === this.dataFilter.action)) {
        this.dataFilter.action = 'eq'
      }

      this.dataFilter.value = ''
    }
  }
}
</script>
