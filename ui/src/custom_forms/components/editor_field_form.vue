<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataField"
      @submit.prevent="submit"
    >
      <FormItem
        :label="i18n['name']"
        prop="display_name"
        :class="dataField.display_name && !isCustomName ? 'mb-0' : ''"
      >
        <VInput
          ref="nameInput"
          v-model="dataField.display_name"
          :placeholder="i18n['field_name']"
          @drag.stop
        />
      </FormItem>
      <p
        v-if="!isCustomName && generatedParamName"
        style="margin-bottom: 6px; font-size: 12px"
      >
        {{ i18n['param_name'] }}: <code>{{ generatedParamName }}</code>
        <Icon
          type="md-create"
          class="ms-1 cursor-pointer"
          @click="toggleCustomParam"
        />
      </p>
      <FormItem
        v-if="isCustomName"
        :label="i18n['param_name']"
        prop="name"
      >
        <VInput
          v-model="dataField.name"
          :placeholder="i18n['request_param']"
          @drag.stop
        />
      </FormItem>
      <FormItem
        :label="i18n['type']"
        prop="field_type"
      >
        <MSelect
          v-model="dataField.field_type"
          :options="fieldTypes"
          :with-deselect="false"
          :placeholder="i18n['input_type']"
          @update:model-value="onTypeChange"
        />
      </FormItem>
      <FormItem
        v-if="dataField.field_type === 'reference'"
        :label="i18n['reference']"
        prop="reference.model_name"
      >
        <MSelect
          v-model="dataField.reference.model_name"
          :value-key="'name'"
          :label-key="'display_name'"
          :with-deselect="false"
          :options="referenceModels"
          :placeholder="i18n['select_resource_placeholder']"
          filterable
          @update:model-value="dataField.default_value = ''"
        />
      </FormItem>
      <FormItem
        v-if="dataField.field_type === 'select'"
        :label="i18n['select_query']"
        prop="select_query_id"
      >
        <QuerySelect v-model="dataField.select_query_id" />
      </FormItem>
      <FormItem
        :label="i18n['default_value']"
        prop="default_value"
      >
        <FormInput
          v-model="dataField.default_value"
          :column="dataField"
        />
      </FormItem>
      <Checkbox
        v-if="dataField.field_type === 'file'"
        v-model="dataField.file_direct_upload"
        class="d-block"
      >
        {{ ' ' }} {{ i18n['send_file_url'] }}
      </Checkbox>
      <Checkbox
        v-if="showMultiple"
        v-model="dataField.is_array"
        class="d-block"
        @update:model-value="resetDefault"
      >
        {{ ' ' }} {{ i18n['multiple'] }}
      </Checkbox>
      <Checkbox
        :model-value="isRequired"
        class="d-block"
        @update:model-value="toggleRequired"
      >
        {{ ' ' }} {{ i18n['required'] }}
      </Checkbox>
      <Checkbox
        :model-value="isConditional"
        class="d-block"
        @update:model-value="toggleConditional"
      >
        {{ ' ' }} {{ i18n['conditional'] }}
      </Checkbox>
      <FieldCondition
        v-if="isConditional"
        v-model="dataField.conditions[0]"
        :fields="filteredConditionFields"
      />
      <Checkbox
        :model-value="isValidate"
        class="d-block mb-3"
        @update:model-value="toggleValidate"
      >
        {{ ' ' }} {{ i18n['validate'] }}
      </Checkbox>
      <template v-if="isValidate">
        <FormItem
          :label="i18n['validation_regexp']"
          :prop="`validators.${dataField.validators.indexOf(customValidator)}.format`"
          :rules="validatorRegexpRule"
        >
          <VInput
            v-model="customValidator.format"
          />
        </FormItem>
        <FormItem
          :label="i18n['error_message']"
          :prop="`validators.${dataField.validators.indexOf(customValidator)}.message`"
          :rules="validatorMessageRule"
        >
          <VInput
            v-model="customValidator.message"
          />
        </FormItem>
      </template>
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove')"
        >
          {{ i18n['remove'] }}
        </VButton>
        <VButton
          @click="$emit('cancel')"
        >
          {{ i18n['cancel'] }}
        </VButton>
      </div>
      <VButton
        type="primary"
        @click="submit"
      >
        {{ okText }}
      </VButton>
    </div>
  </div>
</template>

<script>
import { schema } from 'data_resources/scripts/schema'
import { underscore } from 'utils/scripts/string'
import singularize from 'inflected/src/singularize'
import FormInput from 'data_forms/components/input'
import QuerySelect from 'queries/components/select'
import Validators from 'utils/scripts/validators'
import { i18nDict, fieldRequiredMessage } from 'utils/scripts/i18n'
import FieldCondition from './editor_field_condition'

const MULTIPLE_COLUMN_TYPES = ['input', 'number', 'select', 'reference', 'file', 'json', 'textarea']

export default {
  name: 'FieldForm',
  components: {
    FormInput,
    QuerySelect,
    FieldCondition
  },
  props: {
    field: {
      type: Object,
      required: true
    },
    okText: {
      type: String,
      required: false,
      default: i18nDict.ok
    },
    focus: {
      type: Boolean,
      required: false,
      default: false
    },
    conditionFields: {
      type: Array,
      required: false,
      default: () => []
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'remove', 'cancel'],
  data () {
    return {
      dataField: {},
      isCustomName: false
    }
  },
  computed: {
    filteredConditionFields () {
      return this.conditionFields.filter((field) => {
        return field.value !== this.field.name
      })
    },
    rules () {
      const rules = {
        display_name: [{
          required: true,
          message: fieldRequiredMessage('name')
        }],
        name: [{
          required: true,
          message: fieldRequiredMessage('param_name')
        }],
        field_type: [{
          required: true,
          message: fieldRequiredMessage('field_type')
        }]
      }

      if (this.dataField.field_type === 'json') {
        rules.default_value = [{ validator: Validators.json, fullField: this.i18n.default_value }]
      }

      if (this.dataField.field_type === 'reference') {
        rules['reference.model_name'] = [{
          required: true,
          message: fieldRequiredMessage('reference')
        }]
      }

      if (this.dataField.field_type === 'select') {
        rules.select_query_id = [{
          required: true,
          message: fieldRequiredMessage('query')
        }]
      }

      return rules
    },
    generatedParamName () {
      let name = underscore(this.dataField.display_name)

      if (name === this.dataField.reference?.model_name) {
        name = name + '_id'
      }

      return name
    },
    referenceModels () {
      return schema
    },
    fieldTypes () {
      return [
        { label: this.i18n.text, value: 'input' },
        { label: this.i18n.number, value: 'number' },
        { label: this.i18n.reference, value: 'reference' },
        { label: this.i18n.textarea, value: 'textarea' },
        { label: this.i18n.richtext, value: 'richtext' },
        { label: this.i18n.select, value: 'select' },
        { label: this.i18n.date_and_time, value: 'datetime' },
        { label: this.i18n.date, value: 'date' },
        { label: this.i18n.checkbox, value: 'checkbox' },
        { label: this.i18n.color, value: 'color' },
        { label: this.i18n.file, value: 'file' },
        { label: this.i18n.json, value: 'json' }
      ]
    },
    showMultiple () {
      return MULTIPLE_COLUMN_TYPES.includes(this.dataField.field_type)
    },
    isRequired () {
      return !!this.dataField.validators?.find((validator) => validator.required)
    },
    isValidate () {
      return !!this.customValidator
    },
    isConditional () {
      return !!this.dataField.conditions?.length
    },
    customValidator () {
      return this.dataField.validators?.find((validator) => 'format' in validator)
    },
    validatorRegexpRule () {
      return [
        { required: true, message: fieldRequiredMessage('regexp') },
        { validator: Validators.regexp, fullField: this.i18n.regexp }
      ]
    },
    validatorMessageRule () {
      return [{ required: true, message: fieldRequiredMessage('message') }]
    }
  },
  mounted () {
    if (this.focus) {
      this.$refs.nameInput.$el.querySelector('input').focus()
    }
  },
  created () {
    this.dataField = JSON.parse(JSON.stringify(this.field))

    if (this.dataField.reference) {
      this.dataField.field_type = 'reference'
    }

    if (this.dataField.display_name) {
      this.isCustomName = this.generatedParamName !== this.dataField.name
    }
  },
  methods: {
    onTypeChange (value) {
      this.resetDefault()

      if (!MULTIPLE_COLUMN_TYPES.includes(value)) {
        this.dataField.is_array = false
      }

      if (value === 'reference') {
        const normalizedFieldName = underscore(singularize((this.dataField.display_name || '').toLowerCase())).replace(/_id$/, '')

        const foundModelByName = schema.find((model) => {
          return model.name === normalizedFieldName || model.name === normalizedFieldName.split('_').pop()
        })

        this.dataField.reference = { model_name: foundModelByName?.name || '' }
      } else {
        delete this.dataField.reference
      }
    },
    resetDefault () {
      this.dataField.default_value = this.dataField.is_array ? [] : ''
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          if (!this.isCustomName) {
            this.dataField.name = this.generatedParamName
          }

          if (this.dataField.conditions && !this.dataField.conditions[0]?.field) {
            this.dataField.conditions = []
          }

          this.$emit('submit', this.dataField)
        }
      })
    },
    toggleCustomParam () {
      this.isCustomName = true

      this.dataField.name = this.generatedParamName
    },
    toggleConditional () {
      this.dataField.conditions ||= []

      if (this.isConditional) {
        this.dataField.conditions = []
      } else {
        this.dataField.conditions = [{ field: '', action: 'eq', value: '' }]
      }
    },
    toggleRequired () {
      this.dataField.validators ||= []

      if (this.isRequired) {
        this.dataField.validators = this.dataField.validators.filter((validator) => !validator.required)
      } else {
        this.dataField.validators.push({ required: true })
      }
    },
    toggleValidate () {
      this.dataField.validators ||= []

      if (this.isValidate) {
        this.dataField.validators = this.dataField.validators.filter((validator) => !('format' in validator))
      } else {
        this.dataField.validators.push({ format: '', message: '' })
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.cursor-pointer {
  display: none
}

p:hover {
  .cursor-pointer {
    display: inline
  }
}
</style>
