<template>
  <MSelect
    v-model:selected-options="selectedOptions"
    v-model:selected-option="selectedOption"
    v-model="dataValue"
    filterable
    :size="size"
    :options="data"
    :loading="isLoading"
    :multiple="multiple"
    :remote-function="isSearchableQuery ? loadOptions : null"
    :label-key="labelColumnIndex"
    :value-key="valueColumnIndex"
    :placeholder="i18n['select_placeholder']"
    @update:model-value="onUpdateValue"
    @select="$emit('select', $event)"
  />
</template>

<script>
import { watch } from 'vue'
import api from 'api'
import { loadApiQuery } from 'queries/scripts/api_query'

const LOAD_ITEMS_LIMIT = 100

export default {
  name: 'QueryValueSelect',
  props: {
    modelValue: {
      type: [String, Number, Array],
      required: false,
      default: ''
    },
    queryId: {
      type: [String, Number],
      required: true
    },
    multiple: {
      type: Boolean,
      required: false,
      default: false
    },
    formData: {
      type: Object,
      required: false,
      default: () => ({})
    },
    size: {
      type: String,
      required: false,
      default: 'default'
    }
  },
  emits: ['update:modelValue', 'select'],
  data () {
    return {
      isLoading: false,
      labelColumnIndex: 1,
      valueColumnIndex: 0,
      dataValue: null,
      data: [],
      columns: [],
      selectedOptions: [],
      selectedOption: null,
      query: null
    }
  },
  computed: {
    variablesData () {
      if (this.query && this.formData) {
        return this.query.preferences.variables.reduce((acc, variable) => {
          if (variable.name !== 'search') {
            acc[variable.name] = this.formData[variable.name]
          }

          return acc
        }, {})
      } else {
        return null
      }
    },
    isSearchableQuery () {
      return this.query && this.query.preferences.variables.find((variable) => variable.name === 'search')
    }
  },
  watch: {
    multiple () {
      this.dataValue = null
      this.selectedOption = null
      this.selectedOptions = []
    },
    queryId () {
      this.data = []

      this.loadQuery().then(() => {
        this.loadOptions()
      })
    },
    modelValue (value) {
      if (JSON.stringify(this.dataValue) !== JSON.stringify(this.modelValue)) {
        if (this.modelValue.length && this.isSearchableQuery && this.columns.length) {
          this.loadSelectedOptions().then(() => {
            this.dataValue = JSON.parse(JSON.stringify(this.modelValue))
          })
        } else {
          this.dataValue = JSON.parse(JSON.stringify(this.modelValue))
        }
      }
    }
  },
  mounted () {
    watch(
      () => [this.variablesData, this.modelValue],
      ([oldVars, oldValue], [newVars, newValue]) => {
        if (JSON.stringify(newVars) !== JSON.stringify(oldVars)) {
          if (JSON.stringify(newValue) === JSON.stringify(oldValue) && oldVars !== null && newVars !== null && (Array.isArray(this.modelValue) ? this.modelValue.length : !!this.modelValue)) {
            this.$emit('update:modelValue', this.multiple ? [] : '')
          }

          this.loadOptions()
        }
      },
      { deep: true }
    )
  },
  created () {
    this.dataValue = JSON.parse(JSON.stringify(this.modelValue))

    this.loadQuery().then(() => {
      this.loadOptions().then(() => {
        if (this.modelValue.length && this.isSearchableQuery) {
          this.loadSelectedOptions()
        }
      })
    })
  },
  methods: {
    loadSelectedOptions () {
      return api.get(`run_queries/${this.queryId}`, {
        params: {
          filter: {
            [this.columns[this.valueColumnIndex].name]: this.modelValue
          }
        }
      }).then((result) => {
        this.columns = result.data.meta.columns
        this.selectedOptions = result.data.data

        this.assignOptionIndexesFromColumns(this.columns)
      }).catch((error) => {
        console.error(error)
      })
    },
    onUpdateValue (value) {
      this.$emit('update:modelValue', value)
      this.$emit('select', value)
    },
    loadOptions (query) {
      this.isLoading = true

      const variables = { ...this.variablesData }

      if (this.isSearchableQuery) {
        variables.search = query
      }

      const cacheKey = JSON.stringify(variables) + this.queryId

      this.optionsRespCache ||= {}

      if (this.query?.preferences?.query_type === 'api') {
        this.optionsRespCache[cacheKey] ||= loadApiQuery(this.query, variables)
      } else {
        this.optionsRespCache[cacheKey] ||= api.get(`run_queries/${this.queryId}`, {
          params: {
            variables,
            limit: this.isSearchableQuery ? LOAD_ITEMS_LIMIT : null
          }
        }).then((result) => {
          return {
            data: result.data.data,
            columns: result.data.meta.columns
          }
        })
      }

      return this.optionsRespCache[cacheKey].then((result) => {
        this.columns = result.columns
        this.data = result.data

        this.assignOptionIndexesFromColumns(this.columns)
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    },
    assignOptionIndexesFromColumns (columns) {
      let valueIndex = columns.findIndex((col) => col.name === 'value')
      let labelIndex = columns.findIndex((col) => col.name === 'label')

      if (valueIndex === -1) {
        valueIndex = columns.findIndex((col) => col.name === 'id')
      }

      if (labelIndex === -1) {
        labelIndex = columns.findIndex((col) => col.name === 'name')
      }

      this.valueColumnIndex = valueIndex === -1 ? 0 : valueIndex
      this.labelColumnIndex = labelIndex === -1 ? 1 : labelIndex

      if (columns.length === 1) {
        this.labelColumnIndex = 0
      }
    },
    loadQuery () {
      return api.get(`queries/${this.queryId}`, {
        params: {
          include: 'tags'
        }
      }).then((result) => {
        this.query = result.data.data
      }).catch((error) => {
        console.error(error)

        if (error.response.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        }
      })
    }
  }
}
</script>
