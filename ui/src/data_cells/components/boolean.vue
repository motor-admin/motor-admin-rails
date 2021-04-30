<template>
  <Icon
    v-if="value === 'true' || value === true"
    type="md-checkmark-circle"
    class="text-success fs-2"
  />
  <Icon
    v-else
    type="md-close-circle"
    class="text-danger fs-2"
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
