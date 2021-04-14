<template>
  <VSelect
    v-model="value"
    filterable
    :loading="isLoading"
    :size="size"
    :placeholder="'Select query'"
  >
    <VOption
      v-for="query in queries"
      :key="query.id"
      :value="query.id"
      :label="query.name"
    >
      {{ query.name }}
    </VOption>
  </VSelect>
</template>

<script>
import { queriesStore, loadQueries } from 'reports/scripts/store'

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
