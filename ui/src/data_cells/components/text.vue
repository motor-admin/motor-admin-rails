<template>
  <div
    v-popover="popoverParams"
    :style="textStyle"
    class="text-cell"
  >
    {{ truncatedValue }}
  </div>
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
    textStyle () {
      const style = {}

      if (!this.truncate) {
        style.whiteSpace = 'pre-wrap'
      }

      return style
    },
    popoverParams () {
      return {
        content: this.value,
        trigger: 'mouseenter',
        disabled: true, // !this.isTruncated,
        bodyStyle: {
          maxWidth: '350px',
          overflowY: 'scroll',
          maxHeight: '200px',
          whiteSpace: 'pre-wrap',
          lineBreak: 'anywhere'
        }
      }
    }
  }
}
</script>

<style lang="scss">
.text-cell {
  max-height: 150px;
  overflow-y: auto;
  line-break: anywhere;
}
</style>
