<template>
  <div
    class="text-cell"
    :class="{ 'pre-wrap': !truncate }"
  >
    {{ truncatedValue }}<span
      v-if="isTruncated"
      v-popover="popoverParams"
    >...</span>
  </div>
</template>

<script>
import Truncate from '../mixins/truncate'
import { copyToClipboard } from '../mixins/copy_to_clipboard'

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
  data () {
    return {
      truncateWithoutDots: true
    }
  },
  computed: {
    popoverParams () {
      return {
        content: this.value,
        trigger: 'mouseenter',
        disabled: !this.isTruncated,
        bodyStyle: {
          maxWidth: '350px',
          overflowY: 'auto',
          maxHeight: '200px',
          whiteSpace: 'pre-wrap',
          lineBreak: 'anywhere'
        }
      }
    }
  },
  methods: {
    copyToClipboard
  }
}
</script>

<style lang="scss">
.text-cell {
  max-height: 150px;
  overflow-y: hidden;
  line-break: normal;

  &:hover {
    overflow-y: auto;
  }
}
</style>
