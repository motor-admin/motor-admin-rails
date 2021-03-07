<template>
  <div :class="computedClass">
    <pre>{{ value }}</pre>
  </div>
</template>

<script>
export default {
  name: 'JsonCell',
  props: {
    value: {
      type: [Object, String],
      required: false,
      default: ''
    }
  },
  computed: {
    computedClass () {
      return {
      }
    }
  }
}
</script>

<style lang="scss">
.code-more {
  position: absolute;
  bottom: 0;
  left: 4px;
  right: 4px;
  text-align: center;
  cursor: pointer;
  padding: 5px 0;
}
</style>
