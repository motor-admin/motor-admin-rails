<template>
  <VInput
    :model-value="modelValue"
    size="large"
    :placeholder="i18n['every_day_at_hh_mm']"
    @update:model-value="$emit('update:modelValue', $event)"
  />
  <VButton
    v-for="option in quickSelectOptions"
    :key="option"
    size="small"
    class="me-1"
    @click="$emit('update:modelValue', option)"
  >
    {{ option }}
  </VButton>
</template>

<script>
export default {
  name: 'IntervalInput',
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    }
  },
  emits: ['update:modelValue'],
  computed: {
    quickSelectOptions () {
      return [
        'every day',
        'every Monday',
        'every month'
      ]
    }
  }
}
</script>
