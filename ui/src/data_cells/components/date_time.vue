<template>
  <span v-if="value">{{ formattedDate }}</span>
</template>

<script>
import { formatDate, timeDiff } from 'utils/scripts/date_format'

export default {
  name: 'DateTime',
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
    },
    isDate: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
    formattedDate () {
      return formatDate(this.value, null, this.displayTime, this.isDate)
    },
    timeAgo () {
      return timeDiff(this.value, new Date())
    }
  },
  methods: {
    copyToClipboard () {
      return navigator.clipboard.writeText(this.formattedDate)
    }
  }
}
</script>
