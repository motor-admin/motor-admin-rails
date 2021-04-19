<template>
  <MSelect
    v-model="value"
    filterable
    :size="size"
    :options="queries"
    label-key="name"
    value-key="id"
    :placeholder="'Select query'"
  />
</template>

<script>
import { queriesStore, loadQueries } from 'all_resources/scripts/store'

export default {
  name: 'ResourceSelect',
  props: {
    modelValue: {
      type: [String, Number],
      required: false,
      default: ''
    },
    size: {
      type: String,
      required: false,
      default: 'default'
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      isLoading: true,
      value: ''
    }
  },
  computed: {
    queries () {
      return queriesStore
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
  created () {
    this.value = this.modelValue

    loadQueries().finally(() => {
      this.isLoading = false
    })
  },
  methods: {
  }
}
</script>

<style lang="scss">
</style>
