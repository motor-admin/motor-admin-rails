<template>
  <div
    :class="isPositiveChange ? 'text-success' : 'text-danger'"
  >
    <Icon :type="isPositiveChange ? 'md-arrow-round-up' : 'md-arrow-round-down'" />
    {{ value }}
  </div>
</template>

<script>
import { copyToClipboard } from '../mixins/copy_to_clipboard'

export default {
  name: 'ChangeCell',
  props: {
    value: {
      type: [String, Number],
      required: false,
      default: 0
    }
  },
  computed: {
    isPositiveChange () {
      return !this.value.toString().match(/^-/)
    }
  },
  methods: {
    copyToClipboard
  }
}
</script>
