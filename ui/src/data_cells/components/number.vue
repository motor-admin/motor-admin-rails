<template>
  {{ formattedValue }}
</template>

<script>
import { copyToClipboard } from '../mixins/copy_to_clipboard'

export default {
  name: 'NumberCell',
  props: {
    value: {
      type: [String, Number, Array],
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
      if (Array.isArray(this.value)) {
        return this.value !== null ? JSON.stringify(this.value, null, ' ') : this.value
      } else {
        if (this.withFormat && this.value && typeof this.value === 'number') {
          return Intl.NumberFormat(navigator.language || 'en-US').format(this.value)
        } else {
          return this.value?.toString()
        }
      }
    }
  },
  methods: {
    copyToClipboard
  }
}
</script>
