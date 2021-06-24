<template>
  <div
    v-popover="popoverParams"
    class="text-cell"
    :class="{ 'pre-wrap': !truncate }"
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
    popoverParams () {
      return {
        content: this.value,
        trigger: 'mouseenter',
        disabled: true, // !this.isTruncated,
        bodyStyle: {
          maxWidth: '350px',
          overflowY: 'auto',
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
  overflow-y: hidden;
  line-break: normal;

  &:hover {
    overflow-y: auto;
  }
}
</style>
