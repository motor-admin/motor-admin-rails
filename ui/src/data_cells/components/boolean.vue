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
import { copyToClipboard } from '../mixins/copy_to_clipboard'

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
  },
  methods: {
    copyToClipboard
  }
}
</script>

<style lang="scss">
</style>
