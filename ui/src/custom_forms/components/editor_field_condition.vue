<template>
  <div>
    <MSelect
      v-model="modelValue.field"
      v-model:selected-option="selectedFieldOption"
      filterable
      data-role="condition-field"
      class="mb-2"
      :placeholder="i18n.field"
      :options="fields"
      :with-deselect="false"
      @update:model-value="modelValue.value = ''"
    />
    <MSelect
      v-model="modelValue.action"
      data-role="condition-action"
      class="mb-2"
      filterable
      :with-deselect="false"
      :placeholder="i18n.condition"
      :options="actions"
    />
    <template v-if="!['empty', 'nempty'].includes(modelValue.action)">
      <FormInput
        v-if="selectedFieldOption"
        v-model="modelValue.value"
        class="mb-3"
        :column="selectedFieldOption.field"
        :placeholder="i18n.value"
        data-role="condition-value"
      />
      <VInput
        v-else
        v-model="modelValue.value"
        class="mb-3"
        :placeholder="i18n.value"
        data-role="condition-value"
      />
    </template>
  </div>
</template>

<script>
import FormInput from 'data_forms/components/input'

export default {
  name: 'FieldCondition',
  components: {
    FormInput
  },
  props: {
    modelValue: {
      type: Object,
      required: false,
      default: () => ({})
    },
    fields: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  data () {
    return {
      selectedFieldOption: null
    }
  },
  computed: {
    actions () {
      return [
        { value: 'eq', label: this.i18n.is },
        { value: 'neq', label: this.i18n.is_not },
        { value: 'empty', label: this.i18n.empty },
        { value: 'nempty', label: this.i18n.not_empty },
        { value: 'contains', label: this.i18n.contains },
        { value: 'gt', label: this.i18n.greater_than },
        { value: 'gte', label: this.i18n.greater_or_equal },
        { value: 'lt', label: this.i18n.less_than },
        { value: 'lte', label: this.i18n.less_or_equal }
      ]
    }
  }
}
</script>
