<template>
  <audio
    v-if="value"
    controls
    preload="metadata"
    class="align-middle my-1"
    :src="value"
  />
</template>

<script>
export default {
  name: 'AudioCell',
  props: {
    value: {
      type: [String],
      required: false,
      default: ''
    }
  },
  computed: {
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
