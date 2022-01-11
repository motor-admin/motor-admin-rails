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
  <ColorPicker
    v-else-if="isColor"
    :model-value="modelValue || '#ffffff'"
    :placement="'bottom-start'"
    @update:modelValue="$emit('update:modelValue', $event)"
  />
  <ResourceSelect
    v-else-if="column.reference && column.reference.model_name"
    :model-value="modelValue"
    :resource-name="column.reference.model_name"
    :selected-resource="formData && !column.is_array ? formData[column.reference.name] : null"
    :selected-resources="formData && column.is_array ? formData[column.reference.name] : null"
    :multiple="column.is_array"
    :primary-key="column.reference.primary_key"
    @update:model-value="$emit('update:modelValue', $event)"
    @select="onSelect"
  />
  <QueryValueSelect
    v-else-if="type === 'select' && selectQueryId"
    :model-value="modelValue"
    :query-id="selectQueryId"
    :form-data="formData"
    :multiple="column.is_array"
    @update:modelValue="$emit('update:modelValue', $event)"
    @select="onSelect"
  />
  <MSelect
    v-else-if="isTagSelect"
    :model-value="dataValue"
    :options="tagOptions"
    :allow-create="!tagOptions.length"
    :multiple="column.is_array || !!column.format?.split_tags_by"
    :label-function="tagOptions.length ? (option) => titleize(option.value.toString()) : (option) => option.value.toString()"
    @update:modelValue="$emit('update:modelValue', column.format?.split_tags_by ? $event.join(column.format.split_tags_by) : $event)"
    @select="onSelect"
  />
  <OptionsInput
    v-else-if="isTextareaList"
    :model-value="modelValue"
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
    v-else-if="isTextarea"
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
import OptionsInput from 'utils/components/options_input'
import ColorPicker from 'view3/src/components/color-picker'

export default {
  name: 'FormInput',
  components: {
    ResourceSelect,
    QueryValueSelect,
    VueTrix,
    OptionsInput,
    ColorPicker
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
    selectQueryId () {
      return this.column.select_query_id || this.column.format?.select_query_id
    },
    valueType () {
      return typeof this.modelValue
    },
    type () {
      return this.column.column_type || this.column.field_type
    },
    isTagSelect () {
      return this.type === 'tag' || this.tagOptions.length || (this.column.is_array && ['input', 'number', 'string', 'float', 'integer'].includes(this.type))
    },
    tagOptions () {
      return this.column.format?.select_options || []
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
      return this.type === 'file' || this.type === 'image' || this.column.reference?.model_name === 'active_storage/attachment'
    },
    isNumber () {
      return ['integer', 'bigint', 'int', 'float', 'decimal', 'double', 'number', 'currency', 'change', 'percentage'].includes(this.type)
    },
    isRichtext () {
      return this.type === 'richtext'
    },
    isColor () {
      return this.type === 'color' && (!this.modelValue || this.modelValue.match(/#\w{3,6}/))
    },
    isTextarea () {
      return this.type === 'json' || this.type === 'textarea' || (this.valueType === 'string' && this.modelValue.includes('\n'))
    },
    isTextareaList () {
      return this.type === 'chart'
    }
  },
  watch: {
    type () {
      this.dataValue = ''
      this.$emit('update:modelValue', '')
    }
  },
  created () {
    if (this.modelValue) {
      if (this.isDateTime) {
        this.dataValue = new Date(new Date(this.modelValue).getTime())
      } else if (this.isDate) {
        this.dataValue = new Date(new Date(this.modelValue).getTime() + new Date().getTimezoneOffset() * 60000)
      } else if (this.isTagSelect && this.column.format?.split_tags_by) {
        this.dataValue = this.modelValue.split(this.column.format.split_tags_by).map((e) => e.trim())
      }
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
        this.$emit('update:modelValue', Math.floor(value * 10 ** 8) / 10 ** 6)
      } else {
        this.$emit('update:modelValue', value)
      }
    },
    maybeAdjustCurrencyNumber (value) {
      if (this.type === 'currency' && this.column.format?.currency_base === 'cents') {
        return Math.floor(value * 10 ** 6) / 10 ** 8
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
        if (this.isDateTime) {
          this.$emit('update:modelValue', datetime)
        } else {
          this.$emit('update:modelValue', new Date(datetime.getTime() - datetime.getTimezoneOffset() * 60000))
        }
      } else {
        this.$emit('update:modelValue', '')
      }

      this.$emit('select')
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-input-number, .ivu-date-picker {
  width: 100%
}
</style>
