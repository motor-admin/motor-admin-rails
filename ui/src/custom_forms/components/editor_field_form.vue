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
        label="Name"
        prop="display_name"
        :class="dataField.display_name && !isCustomName ? 'mb-0' : ''"
      >
        <VInput
          ref="nameInput"
          v-model="dataField.display_name"
          placeholder="Field name"
          @drag.stop
        />
      </FormItem>
      <p
        v-if="!isCustomName && generatedParamName"
        style="margin-bottom: 6px; font-size: 12px"
      >
        Param name: <code>{{ generatedParamName }}</code>
        <Icon
          type="md-create"
          class="ms-1 cursor-pointer"
          @click="toggleCustomParam"
        />
      </p>
      <FormItem
        v-if="isCustomName"
        label="Param name"
        prop="name"
      >
        <VInput
          v-model="dataField.name"
          placeholder="Request param"
          @drag.stop
        />
      </FormItem>
      <FormItem
        label="Type"
        prop="field_type"
      >
        <MSelect
          v-model="dataField.field_type"
          :options="fieldTypes"
          placeholder="Input type"
          @update:modelValue="onTypeChange"
        />
      </FormItem>
      <FormItem
        v-if="dataField.field_type === 'reference'"
        label="Reference"
        prop="reference.model_name"
      >
        <MSelect
          v-model="dataField.reference.model_name"
          :value-key="'name'"
          :label-key="'display_name'"
          :options="referenceModels"
          placeholder="Select resource..."
          filterable
          @update:modelValue="dataField.default_value = ''"
        />
      </FormItem>
      <FormItem
        v-if="dataField.field_type === 'select'"
        label="Select query"
        prop="select_query_id"
      >
        <QuerySelect v-model="dataField.select_query_id" />
      </FormItem>
      <FormItem
        label="Default value"
        prop="default_value"
      >
        <FormInput
          v-model="dataField.default_value"
          :column="dataField"
        />
      </FormItem>
      <Checkbox
        v-if="showMultiple"
        v-model="dataField.is_array"
        class="d-block"
        @update:model-value="resetDefault"
      >
        Multiple
      </Checkbox>
      <Checkbox
        :model-value="isRequired"
        class="d-block mb-3"
        @update:model-value="toggleRequired"
      >
        Required
      </Checkbox>
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
          Remove
        </VButton>
        <VButton
          @click="$emit('cancel')"
        >
          Cancel
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
import FormInput from 'data_forms/components/input'
import QuerySelect from 'queries/components/select'
import Validators from 'utils/scripts/validators'

const MULTIPLE_COLUMN_TYPES = ['input', 'number', 'select', 'reference']

export default {
  name: 'FieldForm',
  components: {
    FormInput,
    QuerySelect
  },
  props: {
    field: {
      type: Object,
      required: true
    },
    okText: {
      type: String,
      required: false,
      default: 'OK'
    },
    focus: {
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
  emits: ['submit', 'remove', 'cancel'],
  data () {
    return {
      dataField: {},
      isCustomName: false
    }
  },
  computed: {
    rules () {
      const rules = {
        display_name: [{ required: true }],
        name: [{ required: true }],
        field_type: [{ required: true }]
      }

      if (this.dataField.field_type === 'json') {
        rules.default_value = [{ validator: Validators.json }]
      }

      if (this.dataField.field_type === 'reference') {
        rules['reference.model_name'] = [{ required: true }]
      }

      if (this.dataField.field_type === 'select') {
        rules.select_query_id = [{ required: true }]
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
        { label: 'Text', value: 'input' },
        { label: 'Number', value: 'number' },
        { label: 'Reference', value: 'reference' },
        { label: 'Textarea', value: 'textarea' },
        { label: 'Select', value: 'select' },
        { label: 'Date and Time', value: 'datetime' },
        { label: 'Date', value: 'date' },
        { label: 'Checkbox', value: 'checkbox' },
        { label: 'File', value: 'file' },
        { label: 'JSON', value: 'json' }
      ]
    },
    showMultiple () {
      return MULTIPLE_COLUMN_TYPES.includes(this.dataField.field_type)
    },
    isRequired () {
      return !!this.dataField.validators?.find((validator) => validator.required)
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
        this.dataField.reference = { model_name: '' }
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

          this.$emit('submit', this.dataField)
        }
      })
    },
    toggleCustomParam () {
      this.isCustomName = true

      this.dataField.name = this.generatedParamName
    },
    toggleRequired () {
      this.dataField.validators ||= []

      if (this.isRequired) {
        this.dataField.validators = this.dataField.validators.filter((validator) => !validator.required)
      } else {
        this.dataField.validators.push({ required: true })
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
