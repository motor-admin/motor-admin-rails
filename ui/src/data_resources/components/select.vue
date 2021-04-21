<template>
  <MSelect
    v-model="value"
    filterable
    :remote-function="loadResources"
    :options="options"
    :loading="isLoading"
    :value-key="model.primary_key"
    :label-function="labelFunction"
  />
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import throttle from 'view3/src/utils/throttle'

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
    }
  },
  watch: {
    modelValue (value) {
      this.value = (value || '').toString()
    },
    value (value) {
      this.$emit('update:modelValue', value)
    }
  },
  created () {
    this.value = (this.modelValue || '').toString()
  },
  methods: {
    labelFunction (option) {
      const displayValue = option[this.model.display_column]

      if (displayValue) {
        return `#${option[this.model.primary_key]} ${displayValue}`
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
