<template>
  <template v-if="Array.isArray(normalizedValue)">
    <DataTag
      v-for="(val, index) in normalizedValue"
      :key="index"
      :value="val"
      :format="format"
    />
  </template>
  <div
    v-else-if="value || value == 0"
    class="ivu-tag ivu-tag-size-default ivu-tag-checked cursor-unset position-relative"
    :class="colorClass"
    :style="bgStyle"
  >
    <span
      class="ivu-tag-text ivu-tag-color-white cursor-unset"
      :style="textStyle"
    >{{ options[value] || titleize(value.toString()) }}</span>
    <span
      v-if="withFilterButton"
      class="filter-popup"
      :style="bgStyle"
      :class="colorClass"
      @click.stop="$emit('tag-click', value)"
    >
      <span
        style="vertical-align: middle; margin-bottom: 2px"
        class="ion ion-ios-funnel"
      />
    </span>
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
    },
    format: {
      type: Object,
      required: false,
      default: () => ({})
    },
    withFilterButton: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['tag-click'],
  computed: {
    colorClass () {
      return COLORS[this.value]
    },
    options () {
      return this.format.select_options || {}
    },
    normalizedValue () {
      if (typeof this.value === 'string' && this.format.split_tags_by && this.value.includes(this.format.split_tags_by)) {
        return this.value.split(this.format.split_tags_by).map((e) => e.trim())
      } else {
        return this.value
      }
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

<style lang="scss" scoped>
@import 'utils/styles/variables';
.ivu-tag {
  overflow: visible;
}

.filter-popup {
  display: none;
  width: 15px;
  height: calc(100% + 2px);
  top: -1px;
  right: -12px;
  border-top-right-radius: 3px;
  border-bottom-right-radius: 3px;
  border-left-width: 0 !important;
  position: absolute;
  border-width: 1px;
  border-style: solid;
}

.ivu-tag:hover {
  .filter-popup {
    display: inline;
  }
}
</style>
