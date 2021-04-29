<template>
  <img
    class="table-image"
    :src="value"
  >
</template>

<script>
export default {
  name: 'DataImage',
  props: {
    value: {
      type: String,
      required: true
    }
  }
}
</script>

<style lang="scss">
.table-image {
  max-height: 120px;
  vertical-align: top;
}
</style>
