<template>
  <div class="d-flex">
    <span :style="{ backgroundColor: value, width: '20px', height: '20px', marginRight: '5px' }" />
    {{ value }}
  </div>
</template>

<script>
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
  }
}
</script>
