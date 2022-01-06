<template>
  <MSelect
    v-model="value"
    filterable
    :size="size"
    :options="queries"
    label-key="name"
    value-key="id"
    :placeholder="i18n['select_query']"
  />
</template>

<script>
import { queriesStore, loadQueries } from 'reports/scripts/store'

export default {
  name: 'QuerySelect',
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

    loadQueries()
  },
  methods: {
  }
}
</script>

<style lang="scss">
</style>
