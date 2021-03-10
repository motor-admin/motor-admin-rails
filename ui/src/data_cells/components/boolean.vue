<template>
  <Icon
    v-if="value === 'true' || value === true"
    type="md-checkmark"
    class="text-success"
  />
  <Icon
    v-else
    type="md-close"
    class="text-danger"
  />
</template>

<script>
export default {
  name: 'DataBoolean',
  props: {
    value: {
      type: [Boolean, String],
      required: false,
      default: false
    }
  },
  computed: {
  },
  mounted () {
  }
}
</script>

<style lang="scss">
</style>
