<template>
  <MSelect
    :model-value="modelValue"
    filterable
    :size="size"
    :options="forms"
    label-key="name"
    value-key="id"
    :placeholder="i18n['select_form']"
    :with-create-button="withCreateButton"
    @click-create="goToNewFormPage"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import { formsStore, loadForms } from '../scripts/store'

export default {
  name: 'FormSelect',
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
    },
    withCreateButton: {
      type: Boolean,
      default: false
    },
    createParams: {
      type: Object,
      required: false,
      default: () => ({})
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
  },
  methods: {
    goToNewFormPage () {
      this.$router.push({ name: 'new_form', query: { ...this.createParams } })
    }
  }
}
</script>

<style lang="scss">
</style>
