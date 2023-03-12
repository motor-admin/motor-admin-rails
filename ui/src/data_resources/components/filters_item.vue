<template>
  <div
    class="row"
    data-role="filter-item"
  >
    <div class="col-5 pe-2 ps-0">
      <MSelect
        v-model="dataFilter.key"
        data-role="filter-field"
        filterable
        :with-deselect="false"
        style="margin-left: 50px; width: calc(100% - 50px)"
        :options="columns"
        @update:model-value="onKeyChange"
      />
      <slot />
    </div>
    <div class="col-2 p-0">
      <MSelect
        v-model="dataFilter.action"
        data-role="filter-condition"
        :with-deselect="false"
        :options="actions"
      />
    </div>
    <div class="d-flex col-5 ps-2 pe-0">
      <FormInput
        v-if="selectedColumn && !['contains', 'starts_with', 'ends_with', 'eqnull', 'neqnull'].includes(dataFilter.action) && selectedColumn.column_type !== 'richtext'"
        v-model="dataFilter.value"
        data-role="filter-value"
        :column="selectedColumn"
      />
      <VInput
        v-else
        v-model="dataFilter.value"
        :disabled="['eqnull', 'neqnull'].includes(dataFilter.action)"
        data-role="filter-value"
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

const ACTIONS = ['eq', 'neq', 'eqnull', 'neqnull', 'contains', 'gt', 'gte', 'lt', 'lte', 'starts_with', 'ends_with', 'includes', 'excludes']

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
          if (column.reference && !column.reference.polymorphic && ['read_write', 'read_only'].includes(column.access_type)) {
            const referenceModel = modelNameMap[column.reference.model_name]

            return referenceModel && referenceModel.columns.map((refColumn) => {
              if (!refColumn.virtual && refColumn.column_source !== 'query' && ['read_write', 'read_only'].includes(refColumn.access_type)) {
                return {
                  ...(refColumn.name === column.reference.primary_key ? column : refColumn),
                  value: `${column.reference.name}.${refColumn.name}`,
                  label: `${column.reference.display_name} - ${refColumn.display_name}`
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

            return assocModel && assocModel.columns.map((column) => {
              if (!column.virtual && column.column_source !== 'query' && ['read_write', 'read_only'].includes(column.access_type)) {
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
      ].filter(Boolean)
    },
    actions () {
      const actions = [
        { value: 'eq', label: this.i18n.is },
        { value: 'neq', label: this.i18n.is_not },
        { value: 'eqnull', label: this.i18n.is_null },
        { value: 'neqnull', label: this.i18n.is_not_null }
      ]

      if (!this.selectedColumn) {
        return actions
      }

      if (this.selectedColumn.is_array) {
        actions.push(
          { value: 'includes', label: this.i18n.includes },
          { value: 'excludes', label: this.i18n.excludes }
        )

        return actions
      }

      if (['link', 'image', 'audio', 'video', 'file', 'textarea', 'richtext', 'string', 'tag'].includes(this.selectedColumn.column_type)) {
        actions.push(
          { value: 'contains', label: this.i18n.contains },
          { value: 'starts_with', label: this.i18n.starts_with },
          { value: 'ends_with', label: this.i18n.ends_with }
        )
      } else if (['change', 'percentage', 'integer', 'float', 'date', 'datetime', 'currency'].includes(this.selectedColumn.column_type)) {
        actions.push(
          { value: 'gt', label: this.i18n.greater_than },
          { value: 'gte', label: this.i18n.greater_or_equal },
          { value: 'lt', label: this.i18n.less_than },
          { value: 'lte', label: this.i18n.less_or_equal }
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
