<template>
  <VForm
    ref="form"
    :rules="rules"
    label-position="top"
    :model="variable"
  >
    <FormItem
      label="Input type"
      prop="variable_type"
    >
      <MSelect
        v-model="variable.variable_type"
        :options="variableTypes"
        @update:model-value="onTypeChange"
      />
    </FormItem>
    <FormItem
      v-if="variable.variable_type === 'reference'"
      label="Reference resource"
      prop="reference_resource"
    >
      <MSelect
        v-model="variable.reference_resource"
        label-key="display_name"
        value-key="name"
        placeholder="Select resource..."
        filterable
        :options="schema"
        @update:model-value="$emit('update:variable', variable)"
      />
    </FormItem>
    <FormItem
      v-if="variable.variable_type === 'select'"
      label="Select options"
      prop="select_options"
    >
      <OptionsInput
        v-model="variable.select_options"
        @update:model-value="$emit('update:variable', variable)"
      />
    </FormItem>
    <FormItem
      label="Default value"
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
        { label: 'Text', value: 'text' },
        { label: 'Number', value: 'number' },
        { label: 'Date', value: 'date' },
        { label: 'Reference', value: 'reference' },
        { label: 'Select', value: 'select' }
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
