<template>
  <Spin
    v-if="isLoading && progressIndicatorType == 'spinner'"
    fix
  />
  <progress 
    v-if="isLoading && progressIndicatorType === 'progress-bar'" 
    max="100" 
    :value="uploadProgressValue"
    style="display: block;" />
  <input
    v-if="isFile"
    type="file"
    v-bind="$attrs"
    :multiple="column.is_array"
    @change="onFile"
  >
  <VueTrix
    v-else-if="isRichtext"
    :model-value="modelValue"
    v-bind="$attrs"
    @update:model-value="onRichtextUpdate"
  />
  <ColorPicker
    v-else-if="isColor"
    :model-value="modelValue || '#ffffff'"
    :placement="'bottom-start'"
    v-bind="$attrs"
    @update:model-value="$emit('update:modelValue', $event)"
  />
  <ResourceSelect
    v-else-if="column.reference && column.reference.model_name"
    :model-value="modelValue"
    :resource-name="column.reference.model_name"
    v-bind="$attrs"
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
    v-bind="$attrs"
    @update:model-value="$emit('update:modelValue', $event)"
    @select="onSelect"
  />
  <MSelect
    v-else-if="isTagSelect"
    :model-value="dataValue"
    :options="Array.isArray(tagOptions) ? tagOptions : Object.keys(tagOptions)"
    v-bind="$attrs"
    :allow-create="!Object.entries(tagOptions).length"
    :multiple="column.is_array || !!column.format?.split_tags_by"
    :label-function="Object.entries(tagOptions).length ? (option) => tagOptions[option.value.toString()] || titleize(option.value.toString()) : (option) => option.value.toString()"
    @update:model-value="$emit('update:modelValue', column.format?.split_tags_by ? $event.join(column.format.split_tags_by) : $event)"
    @select="onSelect"
  />
  <OptionsInput
    v-else-if="isTextareaList"
    :model-value="modelValue"
    v-bind="$attrs"
  />
  <Checkbox
    v-else-if="isBoolean"
    v-bind="$attrs"
    :model-value="modelValue"
    @update:model-value="$emit('update:modelValue', $event)"
  />
  <InputNumber
    v-else-if="isNumber"
    :model-value="maybeAdjustCurrencyNumber(modelValue)"
    :parser="numberParser"
    :formatter="numberFormatter"
    v-bind="$attrs"
    @keydown.enter="$emit('enter')"
    @update:model-value="onNumberUpdate"
  />
  <DatePicker
    v-else-if="isDateTime || isDate"
    :type="type"
    :model-value="dataValue"
    v-bind="$attrs"
    @update:model-value="updateDateTime"
  />
  <VInput
    v-else-if="isTextarea"
    v-bind="$attrs"
    :model-value="modelValue"
    type="textarea"
    :autosize="{ minRows: 1, maxRows: 7 }"
    @update:model-value="$emit('update:modelValue', $event)"
  />
  <VInput
    v-else
    :model-value="modelValue"
    v-bind="$attrs"
    :type="column.name === 'password' ? 'password' : 'text'"
    @keydown.enter="$emit('enter')"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import { DirectUpload } from '@rails/activestorage'
import Emitter from 'view3/src/mixins/emitter'
import ResourceSelect from 'data_resources/components/select'
import QueryValueSelect from 'queries/components/value_select'
import VueTrix from 'utils/components/vue_trix'
import { isActiveStorageDirectUploadsEnabled } from 'utils/scripts/configs'
import { titleize } from 'utils/scripts/string'
import ActiveStorageDirectUploader from 'utils/scripts/active_storage_direct_uploader'
import OptionsInput from 'utils/components/options_input'
import ColorPicker from 'view3/src/components/color-picker'
import { divide, times } from 'number-precision'
import api from 'api'

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
  inject: ['formComponent'],
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
      isLoading: false,
      uploadProgressValue: 0,
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
      return ['integer', 'bigint', 'int', 'float', 'decimal', 'double', 'number', 'currency', 'change', 'percentage', 'rating'].includes(this.type)
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
    },
    progressIndicatorType() {
      return isActiveStorageDirectUploadsEnabled ? 'progress-bar' : 'spinner'
    }
  },
  watch: {
    type () {
      this.dataValue = ''
      this.$emit('update:modelValue', '')
    },
    modelValue () {
      this.assignDataValue()
    }
  },
  created () {
    this.assignDataValue()
  },
  methods: {
    titleize,
    assignDataValue () {
      if (this.modelValue) {
        if (this.isDateTime) {
          this.dataValue = new Date(new Date(this.modelValue).getTime())
        } else if (this.isDate) {
          const date = new Date(this.modelValue)
          this.dataValue = new Date(date.getTime() + date.getTimezoneOffset() * 60000)
        } else if (this.isTagSelect && this.column.format?.split_tags_by) {
          this.dataValue = this.modelValue.split(this.column.format.split_tags_by).map((e) => e.trim())
        } else {
          this.dataValue = this.modelValue
        }
      } else if (this.isTagSelect && this.column.format?.split_tags_by) {
        this.dataValue = []
      }
    },
    onFile (event) {
      const promises = [...event.target.files].map((file) => {
        return new Promise((resolve, reject) => {
          const reader = new FileReader()

          reader.readAsBinaryString(file)

          reader.onload = () => {
            if (this.column.file_direct_upload) {
              api.post('data/active_storage__attachments', {
                fields: {
                  attachment: 'id,path,created_at,updated_at,name'
                },
                data: {
                  name: 'attachments',
                  file: {
                    filename: file.name,
                    io: reader.result
                  }
                }
              }).then((result) => {
                resolve(location.origin + result.data.data.path)
              }).catch((error) => {
                reject(error)
              })
            } else if (isActiveStorageDirectUploadsEnabled) {
              const onProgress = (event) => {
                this.uploadProgressValue = event.loaded / event.total * 100
              }

              const uploader = new ActiveStorageDirectUploader(file, '/rails/active_storage/direct_uploads',
                { onProgress: onProgress })

              uploader.uploadFile(file).then(blob => {
                resolve(blob.signed_id)
              }).catch(error => {
                reject(error)
              })
            } else {
              resolve({ filename: file.name, io: reader.result })
            }
          }
        })
      })

      this.isLoading = true

      if (this.formComponent) {
        this.formComponent.isSubmitting = true
      }

      Promise.all(promises).then((result) => {
        if (this.column.is_array) {
          this.$emit('update:modelValue', result)
        } else {
          this.$emit('update:modelValue', result[0])
        }
      }).finally(() => {
        this.isLoading = false

        if (this.formComponent) {
          this.formComponent.isSubmitting = false
        }
      })
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
        this.$emit('update:modelValue', times(value || 0, 100))
      } else {
        this.$emit('update:modelValue', value ?? '')
      }
    },
    maybeAdjustCurrencyNumber (value) {
      if (this.type === 'currency' && this.column.format?.currency_base === 'cents') {
        return divide(value || 0, 100)
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
      } else if (this.dataValue) {
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
