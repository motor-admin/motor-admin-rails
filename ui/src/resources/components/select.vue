<template>
  <VSelect
    v-model="value"
    filterable
    :remote-method="loadResources"
    :loading="isLoading"
  >
    <VOption
      v-for="(option, index) in options"
      :key="index"
      :value="option[model.primary_key]"
    >
      {{ '#' + option[model.primary_key] }} {{ option[model.display_column] }}
    </VOption>
  </VSelect>
</template>

<script>
import api from 'api'
import { modelNameMap } from 'utils/scripts/schema'

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
      this.value = value
    },
    value (value) {
      this.$emit('update:modelValue', value)
    }
  },
  mounted () {
    this.value = this.modelValue
  },
  methods: {
    loadResources (query) {
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
    }
  }
}
</script>

<style lang="scss">
</style>
