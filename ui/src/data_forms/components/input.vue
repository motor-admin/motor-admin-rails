<template>
  <input
    v-if="isFile"
    type="file"
    @change="onFile"
  >
  <VueTrix
    v-else-if="isRichtext"
    :model-value="modelValue"
    @update:modelValue="onRichtextUpdate"
  />
  <ResourceSelect
    v-else-if="column.reference && column.reference.model_name"
    :model-value="modelValue"
    :resource-name="column.reference.model_name"
    :selected-resource="formData ? formData[column.reference.name] : null"
    :multiple="column.is_array"
    :primary-key="column.reference.association_primary_key"
    @update:model-value="$emit('update:modelValue', $event)"
    @select="onSelect"
  />
  <QueryValueSelect
    v-else-if="type === 'select' && column.select_query_id"
    :model-value="modelValue"
    :query-id="column.select_query_id"
    :form-data="formData"
    :multiple="column.is_array"
    @update:modelValue="$emit('update:modelValue', $event)"
    @select="onSelect"
  />
  <MSelect
    v-else-if="isTagSelect"
    :model-value="modelValue"
    :options="tagOptions"
    :allow-create="!tagOptions.length"
    :multiple="column.is_array"
    :label-function="(option) => titleize(option.value.toString())"
    @update:modelValue="$emit('update:modelValue', $event)"
    @select="onSelect"
  />
  <Checkbox
    v-else-if="isBoolean"
    :model-value="modelValue"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <InputNumber
    v-else-if="isNumber"
    :model-value="maybeAdjustCurrencyNumber(modelValue)"
    :parser="numberParser"
    :formatter="numberFormatter"
    @keydown.enter="$emit('enter')"
    @update:modelValue="onNumberUpdate"
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
    :type="column.name === 'password' ? 'password' : 'text'"
    @keydown.enter="$emit('enter')"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
</template>

<script>
import Emitter from 'view3/src/mixins/emitter'
import ResourceSelect from 'data_resources/components/select'
import QueryValueSelect from 'queries/components/value_select'
import VueTrix from 'utils/components/vue_trix'
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
    ResourceSelect,
    QueryValueSelect,
    VueTrix
  },
  mixins: [Emitter],
  props: {
    modelValue: {
      type: [String, Number, Boolean, Date, Object],
      required: false,
      default: ''
    },
    column: {
      type: Object,
      required: true
    },
    formData: {
      type: Object,
      required: false,
      default: null
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
      return this.tagOptions.length || this.column.is_array
    },
    tagOptions () {
      return this.column.validators?.find((validator) => validator.includes?.length)?.includes || []
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
      return ['integer', 'bigint', 'int', 'float', 'decimal', 'double', 'number', 'currency'].includes(this.type)
    },
    isRichtext () {
      return this.type === 'richtext'
    },
    isTextArea () {
      if (this.type === 'input' || this.column.name === 'password') {
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
    numberFormatter (value) {
      if (this.type === 'currency') {
        return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
      } else {
        return value
      }
    },
    numberParser (value) {
      if (this.type === 'currency') {
        return value.replace(/\$\s?|(,*)/g, '')
      } else {
        return value
      }
    },
    onNumberUpdate (value) {
      if (this.type === 'currency' && this.column.format?.currency_base === 'cents') {
        this.$emit('update:modelValue', value * 100)
      } else {
        this.$emit('update:modelValue', value)
      }
    },
    maybeAdjustCurrencyNumber (value) {
      if (this.type === 'currency' && this.column.format?.currency_base === 'cents') {
        return value / 100
      } else {
        return value
      }
    },
    onSelect (value) {
      this.$nextTick(() => {
        this.$emit('select')

        this.dispatch('FormItem', 'on-form-change', value)
      })
    },
    onRichtextUpdate (value) {
      this.$emit('update:modelValue', value)

      this.dispatch('FormItem', 'on-form-change', value)
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
