<template>
  <MSelect
    :key="resourceName"
    v-model="value"
    v-model:selected-options="selectedOptions"
    v-model:selected-option="selectedOption"
    filterable
    :remote-function="loadResources"
    :options="options"
    :loading="isLoading"
    :multiple="multiple"
    :value-key="valueKey"
    :label-function="labelFunction"
  />
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import { truncate } from 'utils/scripts/string'

export default {
  name: 'ResourceSelect',
  props: {
    modelValue: {
      type: [String, Number, Array],
      required: false,
      default: ''
    },
    resourceName: {
      type: String,
      required: true
    },
    multiple: {
      type: Boolean,
      required: false,
      default: false
    },
    primaryKey: {
      type: String,
      required: false,
      default: ''
    },
    selectedResource: {
      type: Object,
      required: false,
      default: null
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      options: [],
      selectedOptions: [],
      selectedOption: null,
      isLoading: false,
      value: this.multiple ? [] : ''
    }
  },
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    },
    valueKey () {
      return this.primaryKey || this.model.primary_key
    }
  },
  watch: {
    modelValue (value) {
      if (this.multiple) {
        if (value?.length && JSON.stringify(value) !== JSON.stringify(this.value)) {
          this.loadMultipleResourceoptionsById(value).then(() => {
            this.value = value || []
          })
        }
      } else {
        this.assignSelectedOption()
      }
    },
    multiple () {
      this.resetData()
    },
    selectedResource () {
      this.selectedOption = this.selectedResource
    },
    resourceName () {
      this.resetData()

      this.loadResources('')
    },
    value (value) {
      this.$emit('update:modelValue', value)
    }
  },
  created () {
    if (this.multiple) {
      if (this.value?.length) {
        this.loadMultipleResourceoptionsById(this.value)
      } else {
        this.value ||= []
      }
    } else {
      this.selectedOption = this.selectedResource

      if (this.selectedOption) {
        this.value = this.modelValue ?? ''
      } else {
        this.assignSelectedOption()
      }
    }
  },
  methods: {
    resetData () {
      this.value = this.multiple ? [] : ''

      this.selectedOption = null
      this.selectedOptions = []
    },
    assignSelectedOption () {
      if (this.modelValue) {
        this.loadMultipleResourceoptionsById([this.modelValue]).then((result) => {
          this.selectedOption = result.data.data[0]

          this.value = this.modelValue ?? ''
        })
      } else {
        this.value = this.modelValue ?? ''
      }
    },
    labelFunction (option) {
      const displayValue = option[this.model.display_column]

      if (this.valueKey === 'id') {
        if (displayValue) {
          return truncate(`#${option[this.valueKey]} ${displayValue}`, 50)
        } else {
          return `#${option[this.valueKey]}`
        }
      } else {
        return truncate(displayValue, 60)
      }
    },
    loadMultipleResourceoptionsById (ids) {
      this.isLoading = true

      const cacheKey = this.model.slug + ids.join()

      this.resourcesRespCache ||= {}
      this.resourcesRespCache[cacheKey] ||= api.get(`data/${this.model.slug}`, {
        params: {
          filter: {
            [this.valueKey]: ids
          }
        }
      })

      return this.resourcesRespCache[cacheKey].then((result) => {
        this.selectedOptions = result.data.data

        return result
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    },
    loadResources (query) {
      const cacheKey = this.model.slug + query

      this.isLoading = true

      this.resourcesRespCache ||= {}
      this.resourcesRespCache[cacheKey] ||= api.get(`data/${this.model.slug}`, {
        params: {
          q: query.includes(' ') ? query.replace(/^#\d+\s/, '') : query.replace(/^#/, ''),
          page: {
            limit: 20
          }
        }
      })

      return this.resourcesRespCache[cacheKey].then((result) => {
        this.options = result.data.data
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>

<style lang="scss">
</style>
