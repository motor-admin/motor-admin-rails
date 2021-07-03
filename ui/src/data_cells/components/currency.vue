<template>
  {{ formattedValue }}
</template>

<script>
export default {
  name: 'CurrencyCell',
  props: {
    value: {
      type: [String, Number],
      required: false,
      default: ''
    },
    format: {
      type: Object,
      required: false,
      default: () => ({})
    }
  },
  computed: {
    formattedValue () {
      const value = this.format.currency_base === 'cents' ? this.value / 100 : this.value

      return Intl.NumberFormat(navigator.language || 'en-US', { style: 'currency', currency: this.format.currency || 'USD' }).format(value)
    }
  },
  methods: {
    copyToClipboard () {
      return navigator.clipboard.writeText(this.formattedValue)
    }
  }
}
</script>
