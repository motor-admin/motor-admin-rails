<template>
  <Rate
    :value="value"
    disabled
    :count="5"
  />
</template>

<script>
import { copyToClipboard } from '../mixins/copy_to_clipboard'

export default {
  name: 'DataRating',
  props: {
    value: {
      type: [String, Number],
      required: false,
      default: ''
    }
  },
  computed: {
  },
  methods: {
    copyToClipboard
  }
}
</script>

<style lang="scss">
</style>
