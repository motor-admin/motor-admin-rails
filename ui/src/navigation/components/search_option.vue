<template>
  <Icon
    :type="iconClasses[option.type]"
  />
  {{ option.value }}
</template>

<script>
export default {
  name: 'SearchOption',
  props: {
    option: {
      type: Object,
      required: true
    }
  },
  computed: {
    iconClasses () {
      return {
        resource: 'md-grid',
        query: 'md-list',
        dashboard: 'md-analytics',
        resource_search: 'md-search',
        resource_id: 'md-open',
        new_query: 'md-create',
        new_dashboard: 'md-create',
        new_alert: 'md-create',
        new_form: 'md-create',
        alert: 'md-notifications',
        form: 'md-list-box'
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.ion {
  width: 20px
}
</style>
