<template>
  <VForm
    ref="form"
    :rules="rules"
    label-position="top"
    :model="variable"
  >
    <FormItem
      v-if="withName"
      :label="i18n['name']"
      prop="name"
    >
      <VInput
        v-model="variable.name"
        :placeholder="i18n.name"
        @update:model-value="updateDisplayName"
      />
    </FormItem>
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

    <Checkbox
      v-if="variable.variable_type === 'reference'"
      v-model="variable.is_array"
      class="d-block"
      @update:model-value="resetDefault"
    >
      {{ ' ' }} {{ i18n['multiple'] }}
    </Checkbox>

    <VButton
      v-if="withRemove"
      long
      type="error"
      ghost
      size="small"
      @click="$emit('remove', variable)"
    >
      {{ i18n.remove }}
    </VButton>
  </VForm>
</template>

<script>
import VariableInput from './variable_input'
import OptionsInput from 'utils/components/options_input'
import { schema } from 'data_resources/scripts/schema'
import { titleize } from 'utils/scripts/string'

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
    },
    withName: {
      type: Boolean,
      required: false,
      default: false
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['update:variable', 'remove'],
  computed: {
    schema: () => schema,
    rules () {
      return {
        name: [{ required: this.withName }]
      }
    },
    variableTypes () {
      return [
        { label: this.i18n.text, value: 'text' },
        { label: this.i18n.number, value: 'number' },
        { label: this.i18n.date, value: 'date' },
        { label: this.i18n.date_and_time, value: 'datetime' },
        { label: this.i18n.reference, value: 'reference' },
        { label: this.i18n.select, value: 'select' }
      ]
    }
  },
  methods: {
    updateDisplayName (value) {
      this.variable.display_name = titleize(value.replace(/_id$/, ''))
    },
    resetDefault () {
      this.variable.default_value = this.variable.is_array ? [] : ''
    },
    onTypeChange () {
      this.variable.default_value = ''

      this.$emit('update:variable', this.variable)
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
