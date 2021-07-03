<template>
  <div class="d-flex">
    <span :style="{ backgroundColor: value, width: '20px', height: '20px', marginRight: '5px' }" />
    {{ value }}
  </div>
</template>

<script>
import { copyToClipboard } from '../mixins/copy_to_clipboard'

export default {
  name: 'ColorCell',
  props: {
    value: {
      type: String,
      required: false,
      default: ''
    }
  },
  computed: {
  },
  methods: {
    copyToClipboard
  }
}
</script>
