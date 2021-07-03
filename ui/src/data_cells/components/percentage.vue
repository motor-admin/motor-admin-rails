<template>
  <Progress
    :percent="percent"
    :stroke-width="20"
    text-inside
  />
</template>

<script>
export default {
  name: 'PercentageCell',
  props: {
    value: {
      type: [String, Number, Array],
      required: false,
      default: 0
    }
  },
  computed: {
    percent () {
      let value
      let successValue = 100

      if (typeof this.value === 'string') {
        value = parseInt(this.value)
      } else if (Array.isArray(this.value)) {
        value = parseInt(this.value[0])
        successValue = parseInt(this.value[1]) || successValue
      } else {
        value = this.value
      }

      return parseInt((value / successValue) * 100)
    }
  },
  methods: {
    copyToClipboard () {
      return navigator.clipboard.writeText(this.percent + '%')
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-progress {
  position: unset;
  width: 180px;

  :deep(&-inner) {
    position: unset;
  }

  :deep(&-bg) {
    position: unset;
  }
}
</style>
