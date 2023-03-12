<template>
  <MSelect
    :key="resourceName"
    v-model:selected-options="selectedOptions"
    v-model:selected-option="selectedOption"
    :model-value="value"
    filterable
    :remote-function="loadResources"
    :options="options"
    :loading="isLoading"
    :multiple="multiple"
    :with-create-button="canCreateNew"
    :value-key="valueKey"
    :label-function="labelFunction"
    @update:model-value="handleValueUpdate"
    @select="$emit('select', $event)"
    @click-create="onCreateClick"
  />
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import { buildDefaultValues } from '../scripts/form_utils'
import { truncate } from 'utils/scripts/string'
import { defineAsyncComponent } from 'vue'
import { fieldsParams } from 'data_resources/scripts/query_utils'
import singularize from 'inflected/src/singularize'

const ResourceForm = defineAsyncComponent(() => import('./form'))
const CustomFormWrapper = defineAsyncComponent(() => import('custom_forms/components/form_wrapper'))

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
    },
    selectedResources: {
      type: Array,
      required: false,
      default: () => ([])
    }
  },
  emits: ['update:modelValue', 'select'],
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
    canCreateNew () {
      return !!this.createAction?.visible
    },
    createAction () {
      return this.model.actions.find((a) => a.name === 'create')
    },
    valueKey () {
      return this.primaryKey || this.model.primary_key
    },
    customCreateActionProps () {
      return {
        data: buildDefaultValues(this.model),
        formId: this.createAction.preferences.form_id,
        withFooterSubmit: true,
        withSuccessMessage: false,
        onClose: () => {
          this.$Modal.remove()
        },
        onSuccess: (result) => {
          this.onCreateSuccess(result.data.data || result.data[this.model.name] || result.data)

          this.$Modal.remove()
        }
      }
    },
    defaultCreateProps () {
      return {
        action: 'new',
        resource: buildDefaultValues(this.model),
        resourceName: this.model.name,
        withSaveAndCreateNew: false,
        onClose: () => {
          this.$Modal.remove()
        },
        onSuccess: (result) => {
          this.onCreateSuccess(result.data.data)
        }
      }
    }
  },
  watch: {
    modelValue (value) {
      if (this.multiple) {
        if (value?.length && JSON.stringify(value) !== JSON.stringify(this.value)) {
          this.loadMultipleResourceoptionsById(value).then(() => {
            this.value = value || []
          })
        } else if (!value || !value.length) {
          this.selectedOptions = []
        }
      } else {
        if (this.value !== value) {
          this.assignSelectedOption()
        }
      }
    },
    multiple () {
      this.resetData()
    },
    selectedResource () {
      this.selectedOption = this.selectedResource
    },
    selectedResources () {
      this.selectedOptions = this.selectedResources
    },
    resourceName () {
      this.resetData()

      this.loadResources('')
    }
  },
  created () {
    if (this.multiple) {
      if (this.selectedResources?.length) {
        this.selectedOptions = [...this.selectedResources]
        this.options = [...this.selectedResources]
        this.value = this.modelValue
      } else if (this.value?.length) {
        this.loadMultipleResourceoptionsById(this.value)
      } else if (this.modelValue && typeof this.modelValue === 'object') {
        this.value = Object.values(this.modelValue)
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
    handleValueUpdate (value) {
      if (value !== this.value) {
        this.value = value
        this.$emit('update:modelValue', value)
      }
    },
    onCreateSuccess (data) {
      this.selectedOption = data

      if (this.multiple) {
        this.value.push(data[this.valueKey])
      } else {
        this.value = data[this.valueKey]
      }

      this.$emit('update:modelValue', this.value)
    },
    onCreateClick () {
      const component = this.createAction.action_type === 'default' ? ResourceForm : CustomFormWrapper
      const props = this.createAction.action_type === 'default' ? this.defaultCreateProps : this.customCreateActionProps

      this.$Modal.open(component, props, {
        title: `${this.createAction.display_name} ${singularize(this.model.display_name)}`,
        closable: true
      })
    },
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
        this.selectedOption = null
      }
    },
    labelFunction (option) {
      const displayValue = option[this.model.display_column]

      if (this.valueKey === 'id') {
        if (displayValue) {
          return truncate(`#${option[this.valueKey]} ${displayValue}`, 200)
        } else {
          return `#${option[this.valueKey]}`
        }
      } else {
        return truncate(displayValue, 220)
      }
    },
    loadMultipleResourceoptionsById (ids) {
      this.isLoading = true

      const cacheKey = this.model.slug + (Array.isArray(ids) ? ids.join() : ids)

      this.resourcesRespCache ||= {}
      this.resourcesRespCache[cacheKey] ||= api.get(`data/${this.model.slug}`, {
        params: {
          fields: fieldsParams(this.model),
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
          fields: fieldsParams(this.model),
          page: {
            limit: 100
          }
        }
      })

      return this.resourcesRespCache[cacheKey].then((result) => {
        if (!query && this.multiple) {
          this.options = [
            ...this.selectedOptions,
            ...result.data.data.filter((item) => !this.value.includes(item[this.model.primary_key]))
          ]
        } else {
          this.options = result.data.data
        }
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
