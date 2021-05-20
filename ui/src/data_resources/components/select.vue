<template>
  <MSelect
    v-model="value"
    filterable
    :remote-function="loadResources"
    :options="options"
    :loading="isLoading"
    :value-key="valueKey"
    :label-function="labelFunction"
  />
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import throttle from 'view3/src/utils/throttle'
import { truncate } from 'utils/scripts/string'

export default {
  name: 'ResourceSelect',
  props: {
    modelValue: {
      type: [String, Number],
      required: false,
      default: ''
    },
    resourceName: {
      type: String,
      required: true
    },
    primaryKey: {
      type: String,
      required: false,
      default: ''
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      options: [],
      isLoading: false,
      value: ''
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
      this.value = (value ?? '').toString()
    },
    resourceName () {
      this.value = ''
      this.loadResources('')
    },
    value (value) {
      this.$emit('update:modelValue', value)
    }
  },
  created () {
    this.value = (this.modelValue ?? '').toString()
  },
  methods: {
    labelFunction (option) {
      const displayValue = option[this.model.display_column]

      if (displayValue) {
        return truncate(`#${option[this.model.primary_key]} ${displayValue}`, 50)
      } else {
        return `#${option[this.model.primary_key]}`
      }
    },
    loadResources: throttle(function (query) {
      this.isLoading = true

      return api.get(`data/${this.model.slug}`, {
        params: {
          q: query.includes(' ') ? query.replace(/^#\d+\s/, '') : query.replace(/^#/, ''),
          page: {
            limit: 20
          }
        }
      }).then((result) => {
        this.options = result.data.data
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }, 500)
  }
}
</script>

<style lang="scss">
</style>
