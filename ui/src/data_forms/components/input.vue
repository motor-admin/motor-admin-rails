<template>
  <ResourceSelect
    v-if="column.reference && column.reference.name"
    :model-value="modelValue"
    :resource-name="column.reference.name"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <input
    v-else-if="isFile"
    type="file"
    @change="onFile"
  >
  <MSelect
    v-else-if="isTagSelect"
    :model-value="modelValue"
    :options="tagOptions"
    :label-function="(option) => titleize(option.value)"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
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
    :type="type"
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
  emits: ['update:modelValue'],
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
      return this.column.validators.find((validator) => validator.includes?.length)?.includes
    },
    isBoolean () {
      return this.type === 'boolean' || this.type === 'checkbox'
    },
    isDateTime () {
      return this.type === 'datetime'
    },
    isDate () {
      return this.type === 'date'
    },
    isFile () {
      return this.type === 'file'
    },
    isNumber () {
      return ['integer', 'bigint', 'int', 'float', 'demical', 'double', 'number'].includes(this.type)
    },
    isTextArea () {
      if (this.column.field_type === 'input') {
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
    column () {
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
    updateDateTime (datetime) {
      if (datetime) {
        this.$emit('update:modelValue', new Date(datetime.getTime() - datetime.getTimezoneOffset() * 60000))
      }
    }
  }
}
</script>
