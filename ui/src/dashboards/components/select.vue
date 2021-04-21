<template>
  <MSelect
    :model-value="modelValue"
    filterable
    :size="size"
    :options="dashboards"
    label-key="title"
    value-key="id"
    :placeholder="'Select dashboard'"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import { dashboardsStore, loadDashboards } from 'reports/scripts/store'

export default {
  name: 'DashboardSelect',
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
  computed: {
    dashboards () {
      return dashboardsStore
    }
  },
  created () {
    loadDashboards()
  },
  methods: {
  }
}
</script>

<style lang="scss">
</style>
