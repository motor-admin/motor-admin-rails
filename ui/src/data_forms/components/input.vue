<template>
  <ResourceSelect
    v-if="column.reference"
    :model-value="modelValue"
    :resource-name="column.reference.name"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <VSelect
    v-else-if="isTagSelect"
    :model-value="modelValue"
    @update:modelValue="$emit('update:modelValue', $event)"
  >
    <VOption
      v-for="option in tagOptions"
      :key="option"
      :value="option"
    >
      {{ titleize(option) }}
    </VOption>
  </VSelect>
  <Checkbox
    v-else-if="isBoolean"
    :model-value="modelValue"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <InputNumber
    v-else-if="isNumber"
    :model-value="modelValue"
    :style="{ width: '100%' }"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <DatePicker
    v-else-if="isDateTime || isDate"
    :type="column.column_type"
    :model-value="dataValue"
    :style="{ width: '100%' }"
    @update:modelValue="updateDateTime"
  />
  <VInput
    v-else-if="isTextArea"
    :model-value="modelValue"
    type="textarea"
    :autosize="{ minRows: 1, maxRows: 7 }"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <VInput
    v-else
    :model-value="modelValue"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
</template>

<script>
import ResourceSelect from 'resources/components/select'
import { titleize } from 'utils/scripts/string'

const SINGLE_LINE_INPUT_NAMES = [
  'name',
  'title',
  'brand',
  'make',
  'model',
  'phone',
  'email',
  'company',
  'url',
  'link',
  'domain'
]

const SINGLE_LINE_INPUT_REGEXP = new RegExp(SINGLE_LINE_INPUT_NAMES.join('|'))

export default {
  name: 'FormInput',
  components: {
    ResourceSelect
  },
  props: {
    modelValue: {
      type: [String, Number, Boolean, Date],
      required: false,
      default: ''
    },
    column: {
      type: Object,
      required: true
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      dataValue: this.modelValue
    }
  },
  computed: {
    isTagSelect () {
      return !!this.tagOptions
    },
    tagOptions () {
      return this.column.validators.find((validator) => validator.includes?.length)?.includes
    },
    isBoolean () {
      return this.column.column_type === 'boolean'
    },
    isDateTime () {
      return this.column.column_type === 'datetime'
    },
    isDate () {
      return this.column.column_type === 'date'
    },
    isNumber () {
      return ['integer', 'bigint', 'int', 'float', 'demical', 'double'].includes(this.column.column_type)
    },
    isTextArea () {
      if (['json', 'jsonb'].includes(this.column.column_type)) {
        return true
      } else if (!this.column.name.match(SINGLE_LINE_INPUT_REGEXP)) {
        return true
      } else {
        return false
      }
    }
  },
  methods: {
    titleize,
    updateDateTime (datetime) {
      if (datetime) {
        this.$emit('update:modelValue', new Date(datetime.getTime() - datetime.getTimezoneOffset() * 60000))
      }
    }
  }
}
</script>
