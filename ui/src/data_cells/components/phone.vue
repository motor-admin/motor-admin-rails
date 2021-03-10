<template>
  <a
    :href="`tel:${value}`"
    target="_blank"
    rel="nofollow"
    @click.stop
  >
    {{ truncatedValue }}
  </a>
</template>

<script>
import Truncate from '../mixins/truncate'

export default {
  name: 'DataPhone',
  mixins: [Truncate],
  props: {
    value: {
      type: [String],
      required: false,
      default: ''
    }
  },
  computed: {
  }
}
</script>

<style lang="scss">
</style>
