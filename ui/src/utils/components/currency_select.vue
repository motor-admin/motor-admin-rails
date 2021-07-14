<template>
  <MSelect
    :model-value="modelValue"
    filterable
    :options="currencyOptions"
    :with-deselect="false"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import { ISO_CODES } from 'utils/scripts/currencies'

export default {
  name: 'CurrencySelect',
  props: {
    modelValue: {
      type: [String],
      required: false,
      default: 'USD'
    }
  },
  emits: ['update:modelValue'],
  computed: {
    currencyOptions () {
      return ISO_CODES
    }
  }
}
</script>
