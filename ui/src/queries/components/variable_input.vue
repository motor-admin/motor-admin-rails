<template>
  <FormInput
    :model-value="modelValue"
    :column="columnProps"
    @select="$emit('select')"
    @enter="$emit('enter')"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import FormInput from 'data_forms/components/input'

export default {
  name: 'VariableInput',
  components: {
    FormInput
  },
  props: {
    modelValue: {
      type: [Date, Number, String, Object, Array],
      required: false,
      default: ''
    },
    variable: {
      type: Object,
      required: true
    }
  },
  emits: ['update:modelValue', 'select', 'enter'],
  computed: {
    columnProps () {
      const variableType = this.variable.variable_type || 'text'

      const props = {
        name: this.variable.name,
        column_type: variableType === 'text' ? 'input' : variableType,
        is_array: !!this.variable.is_array
      }

      if (variableType === 'reference') {
        props.reference = { model_name: this.variable.reference_resource }
      }

      if (variableType === 'select') {
        if (this.variable.select_options?.length) {
          props.format = { select_options: this.variable.select_options }
        } else {
          props.column_type = 'input'
        }
      }

      return props
    }
  },
  watch: {
    'variable.variable_type' () {
      this.$emit('update:modelValue', '')
    },
    'variable.is_array' (value) {
      this.$emit('update:modelValue', value ? [] : '')
    }
  }
}
</script>
