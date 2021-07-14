<template>
  <VForm
    ref="form"
    :rules="rules"
    label-position="top"
    :model="variable"
  >
    <FormItem
      :label="i18n['input_type']"
      prop="variable_type"
    >
      <MSelect
        v-model="variable.variable_type"
        :options="variableTypes"
        :with-deselect="false"
        @update:model-value="onTypeChange"
      />
    </FormItem>
    <FormItem
      v-if="variable.variable_type === 'reference'"
      :label="i18n['reference_resource']"
      prop="reference_resource"
    >
      <MSelect
        v-model="variable.reference_resource"
        :with-deselect="false"
        label-key="display_name"
        value-key="name"
        :placeholder="i18n['select_resource_placeholder']"
        filterable
        :options="schema"
        @update:model-value="$emit('update:variable', variable)"
      />
    </FormItem>
    <FormItem
      v-if="variable.variable_type === 'select'"
      :label="i18n['select_options']"
      prop="select_options"
    >
      <OptionsInput
        v-model="variable.select_options"
        @update:model-value="$emit('update:variable', variable)"
      />
    </FormItem>
    <FormItem
      :label="i18n['default_value']"
      prop="default_value"
    >
      <VariableInput
        v-model="variable.default_value"
        :variable="variable"
        @update:model-value="$emit('update:variable', variable)"
      />
    </FormItem>
  </VForm>
</template>

<script>
import VariableInput from './variable_input'
import OptionsInput from 'utils/components/options_input'
import { schema } from 'data_resources/scripts/schema'

export default {
  name: 'VariableSettings',
  components: {
    VariableInput,
    OptionsInput
  },
  props: {
    variable: {
      type: Object,
      required: true
    }
  },
  emits: ['update:variable'],
  computed: {
    schema: () => schema,
    rules () {
      return []
    },
    variableTypes () {
      return [
        { label: this.i18n.text, value: 'text' },
        { label: this.i18n.number, value: 'number' },
        { label: this.i18n.date, value: 'date' },
        { label: this.i18n.reference, value: 'reference' },
        { label: this.i18n.select, value: 'select' }
      ]
    }
  },
  methods: {
    onTypeChange () {
      this.variable.default_value = ''

      this.$emit('update:variable', this.variable)
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
