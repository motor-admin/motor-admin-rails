<template>
  <MSelect
    :model-value="modelValue"
    filterable
    :size="size"
    :options="dashboards"
    label-key="title"
    value-key="id"
    :with-deselect="withDeselect"
    :placeholder="i18n['select_dashboard']"
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
    },
    withDeselect: {
      type: Boolean,
      required: false,
      default: true
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
