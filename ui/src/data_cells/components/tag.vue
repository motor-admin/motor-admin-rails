<template>
  <div
    class="ivu-tag ivu-tag-size-default ivu-tag-checked"
    :class="colorClass"
    :style="bgStyle"
  >
    <span
      class="ivu-tag-text ivu-tag-color-white"
      :style="textStyle"
    >{{ normalized }}</span>
  </div>
</template>

<script>
import { colorsForTag } from '../scripts/tag_colors'

const COLORS = {
  ok: 'ivu-tag-green',
  done: 'ivu-tag-green',
  available: 'ivu-tag-green',
  completed: 'ivu-tag-green',
  valid: 'ivu-tag-green',
  fail: 'ivu-tag-red',
  failed: 'ivu-tag-red',
  undone: 'ivu-tag-orange',
  interrupt: 'ivu-tag-orange',
  interrupted: 'ivu-tag-orange',
  unavailable: 'ivu-tag-orange',
  progress: 'ivu-tag-orange',
  in_progress: 'ivu-tag-blue',
  pending: 'ivu-tag-blue',
  enabled: 'ivu-tag-green',
  resolved: 'ivu-tag-green',
  disabled: 'ivu-tag-red',
  invalid: 'ivu-tag-red'
}

export default {
  name: 'DataTag',
  props: {
    value: {
      type: String,
      required: true
    }
  },
  computed: {
    colorClass () {
      return COLORS[this.value]
    },
    tagColors () {
      return colorsForTag(this.value)
    },
    bgStyle () {
      return this.colorClass ? '' : `background: ${this.tagColors[0]}; border: 1px solid ${this.tagColors[1]}`
    },
    textStyle () {
      return this.colorClass ? '' : `color: ${this.tagColors[1]} !important`
    },
    normalized () {
      return this.value.replace(/_+/g, ' ').replace(/(^|\s)\S/g, (t) => t.toUpperCase())
    }
  }
}
</script>

<style>
</style>
