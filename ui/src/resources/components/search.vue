<template>
  <VInput
    v-model="value"
    search
    :placeholder="placeholder"
    @on-search="onSearch"
  />
</template>

<script>
export default {
  name: 'ResourceSearch',
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    placeholder: {
      type: String,
      required: false,
      default: 'Search...'
    }
  },
  emits: ['search', 'update:modelValue'],
  data () {
    return {
      value: ''
    }
  },
  watch: {
    modelValue (value) {
      this.value = value
    }
  },
  mounted () {
    this.value = this.modelValue
  },
  methods: {
    onSearch () {
      this.$emit('update:modelValue', this.value)
      this.$emit('search', this.value)
    }
  }
}
</script>

<style lang="scss">
</style>
