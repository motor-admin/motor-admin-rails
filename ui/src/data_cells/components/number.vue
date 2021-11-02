<template>
  {{ formattedValue }}
</template>

<script>
import { copyToClipboard } from '../mixins/copy_to_clipboard'

export default {
  name: 'NumberCell',
  props: {
    value: {
      type: [String, Number],
      required: false,
      default: ''
    },
    withFormat: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
    formattedValue () {
      if (this.withFormat && this.value) {
        return Intl.NumberFormat(navigator.language || 'en-US').format(this.value)
      } else {
        return this.value.toString()
      }
    }
  },
  methods: {
    copyToClipboard
  }
}
</script>
