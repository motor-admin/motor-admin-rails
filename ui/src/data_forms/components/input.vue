<template>
  <input
    v-if="isFile"
    type="file"
    @change="onFile"
  >
  <ResourceSelect
    v-else-if="column.reference && column.reference.model_name"
    :model-value="modelValue"
    :resource-name="column.reference.model_name"
    @update:modelValue="onSelect"
  />
  <MSelect
    v-else-if="isTagSelect"
    :model-value="modelValue"
    :options="tagOptions"
    :label-function="(option) => titleize(option.value.toString())"
    @update:modelValue="onSelect"
  />
  <Checkbox
    v-else-if="isBoolean"
    :model-value="modelValue"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <InputNumber
    v-else-if="isNumber"
    :model-value="modelValue"
    @keydown.enter="$emit('enter')"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <DatePicker
    v-else-if="isDateTime || isDate"
    :type="type"
    :model-value="dataValue"
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
    @keydown.enter="$emit('enter')"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
</template>

<script>
import ResourceSelect from 'data_resources/components/select'
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
      type: [String, Number, Boolean, Date, Object],
      required: false,
      default: ''
    },
    column: {
      type: Object,
      required: true
    }
  },
  emits: ['update:modelValue', 'select', 'enter'],
  data () {
    return {
      dataValue: this.modelValue
    }
  },
  computed: {
    type () {
      return this.column.column_type || this.column.field_type
    },
    isTagSelect () {
      return !!this.tagOptions
    },
    tagOptions () {
      return this.column.validators?.find((validator) => validator.includes?.length)?.includes
    },
    isBoolean () {
      return typeof this.modelValue === 'boolean' || this.type === 'boolean' || this.type === 'checkbox'
    },
    isDateTime () {
      return this.type === 'datetime'
    },
    isDate () {
      return this.type === 'date'
    },
    isFile () {
      return this.type === 'file' || this.type === 'image'
    },
    isNumber () {
      return ['integer', 'bigint', 'int', 'float', 'demical', 'double', 'number', 'currency'].includes(this.type)
    },
    isTextArea () {
      if (this.type === 'input') {
        return false
      }

      if (this.type === 'json' || this.type === 'textarea') {
        return true
      } else if (!this.column.name.match(SINGLE_LINE_INPUT_REGEXP)) {
        return true
      } else {
        return false
      }
    }
  },
  watch: {
    type () {
      this.dataValue = ''
      this.$emit('update:modelValue', '')
    }
  },
  methods: {
    titleize,
    onFile (event) {
      const file = event.target.files[0]
      const reader = new FileReader()

      reader.readAsBinaryString(file)

      reader.onload = () => {
        this.$emit('update:modelValue', {
          filename: file.name,
          io: reader.result
        })
      }
    },
    onSelect (value) {
      if (value) {
        this.$emit('update:modelValue', value)
        this.$emit('select')
      }
    },
    updateDateTime (datetime) {
      if (datetime) {
        this.$emit('update:modelValue', new Date(datetime.getTime() - datetime.getTimezoneOffset() * 60000))
        this.$emit('select')
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-input-number, .ivu-date-picker {
  width: 100%
}
</style>
