<template>
  <video
    v-if="isTable && value"
    :src="value"
    class="table-image"
  />
  <video
    v-else-if="value"
    :src="value"
    style="width: 100%"
    controls
  />
</template>

<script>
export default {
  name: 'DataVideo',
  props: {
    value: {
      type: String,
      required: true
    },
    isTable: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  methods: {
    copyToClipboard () {
      const url = this.value[0] === '/' ? document.location.origin + this.value : this.value

      return navigator.clipboard.writeText(url)
    }
  }
}
</script>

<style lang="scss">
</style>
