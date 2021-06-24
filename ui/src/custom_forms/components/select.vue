<template>
  <MSelect
    :model-value="modelValue"
    filterable
    :size="size"
    :options="forms"
    label-key="name"
    value-key="id"
    :placeholder="i18n['select_form']"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import { formsStore, loadForms } from '../scripts/store'

export default {
  name: 'ResourceSelect',
  props: {
    modelValue: {
      type: [String, Number],
      required: false,
      default: ''
    },
    size: {
      type: String,
      required: false,
      default: 'default'
    }
  },
  emits: ['update:modelValue'],
  computed: {
    forms () {
      return formsStore
    }
  },
  mounted () {
    loadForms()
  }
}
</script>

<style lang="scss">
</style>
