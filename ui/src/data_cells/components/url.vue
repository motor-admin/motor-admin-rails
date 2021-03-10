<template>
  <a
    :href="value"
    target="_blank"
    rel="nofollow"
    class="text-break-all"
    @click.stop
  >
    {{ truncatedValue }}
  </a>
</template>

<script>
import Truncate from '../mixins/truncate'

export default {
  name: 'TextCell',
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
