<template>
  <svg
    v-if="Array.isArray(value)"
    viewBox="0 0 300 105"
    width="100%"
    style="max-width: 200px"
  >
    <polyline
      fill="none"
      stroke="#408ccf"
      stroke-width="4"
      :points="points"
    />
  </svg>
</template>

<script>
import { copyToClipboard } from '../mixins/copy_to_clipboard'

export default {
  name: 'ChartCell',
  props: {
    value: {
      type: [String, Number, Array],
      required: false,
      default: 0
    }
  },
  computed: {
    stepX () {
      return parseInt(300 / (this.value.length - 1))
    },
    maxValue () {
      return Math.max(...this.value)
    },
    points () {
      return this.value.map((val, index) => {
        return `${index * this.stepX},${102 - (this.maxValue ? parseInt((val * 100) / this.maxValue) : 0)}`
      }).join('\n')
    }
  },
  methods: {
    copyToClipboard
  }
}
</script>

<style lang="scss" scoped>
</style>
