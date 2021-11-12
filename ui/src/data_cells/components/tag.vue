<template>
  <template v-if="Array.isArray(value)">
    <DataTag
      v-for="(val, index) in value"
      :key="index"
      :value="val"
    />
  </template>
  <div
    v-else-if="value"
    class="ivu-tag ivu-tag-size-default ivu-tag-checked cursor-unset"
    :class="colorClass"
    :style="bgStyle"
  >
    <span
      class="ivu-tag-text ivu-tag-color-white cursor-unset"
      :style="textStyle"
    >{{ titleize(value.toString()) }}</span>
  </div>
</template>

<script>
import { colorsForTag } from '../scripts/tag_colors'
import { titleize } from 'utils/scripts/string'
import { copyToClipboard } from '../mixins/copy_to_clipboard'

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
      type: [String, Array, Number],
      required: false,
      default: () => []
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
    }
  },
  methods: {
    titleize,
    copyToClipboard
  }
}
</script>

<style>
</style>
