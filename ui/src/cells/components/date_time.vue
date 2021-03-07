<template>
  <span>{{ formattedDate }}</span>
</template>

<script>
import { formatDate, timeDiff } from 'utils/scripts/date_format'

export default {
  name: 'DateTimeCell',
  props: {
    value: {
      type: String,
      required: false,
      default: ''
    },
    displayTime: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  computed: {
    formatOptions () {
      const options = {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      }

      if (this.displayTime) {
        options.hour = 'numeric'
        options.minute = 'numeric'
        options.hour12 = true
      }

      return options
    },
    formattedDate () {
      return formatDate(this.value, this.formatOptions)
    },
    timeAgo () {
      return timeDiff(this.value, new Date())
    }
  }
}
</script>
