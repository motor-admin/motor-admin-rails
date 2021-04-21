<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataField"
    >
      <FormItem
        label="Name"
        prop="display_name"
      >
        <VInput
          v-model="dataField.display_name"
          placeholder="Field name"
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
        prop="reference.name"
      >
        <MSelect
          v-model="dataField.reference.name"
          :value-key="'name'"
          :label-key="'display_name'"
          :options="referenceModels"
          placeholder="Select resource..."
          filterable
          @update:modelValue="dataField.default_value = ''"
        />
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
      <FormItem
        label="Required"
      >
        <Checkbox
          :model-value="isRequired"
          @update:model-value="toggleRequired"
        />
      </FormItem>
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
        Save
      </VButton>
    </div>
  </div>
</template>

<script>
import { schema } from 'data_resources/scripts/schema'
import { underscore } from 'utils/scripts/string'
import FormInput from 'data_forms/components/input'
import Validators from 'utils/scripts/validators'

export default {
  name: 'FieldForm',
  components: {
    FormInput
  },
  props: {
    field: {
      type: Object,
      required: true
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
      dataField: {}
    }
  },
  computed: {
    rules () {
      const rules = {
        display_name: [{ required: true }],
        field_type: [{ required: true }]
      }

      if (this.dataField.field_type === 'json') {
        rules.default_value = [{ validator: Validators.json }]
      }

      return rules
    },
    referenceModels () {
      return schema.filter((model) => model.visible)
    },
    fieldTypes () {
      return [
        { label: 'Text', value: 'input' },
        { label: 'Number', value: 'number' },
        { label: 'Reference', value: 'reference' },
        { label: 'Textarea', value: 'textarea' },
        { label: 'Date and Time', value: 'datetime' },
        { label: 'Date', value: 'date' },
        { label: 'Checkbox', value: 'checkbox' },
        { label: 'File', value: 'file' },
        { label: 'JSON', value: 'json' }
      ]
    },
    isRequired () {
      return !!this.dataField.validators?.find((validator) => validator.required)
    }
  },
  created () {
    this.dataField = JSON.parse(JSON.stringify(this.field))

    if (this.dataField.reference) {
      this.dataField.field_type = 'reference'
    }
  },
  methods: {
    onTypeChange (value) {
      this.dataField.default_value = ''

      if (value === 'reference') {
        this.dataField.reference = { name: '' }
      } else {
        delete this.dataField.reference
      }
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.dataField.name = underscore(this.dataField.display_name)

          if (this.dataField.name === this.dataField.reference?.name) {
            this.dataField.name = this.dataField.name + '_id'
          }

          this.$emit('submit', this.dataField)
        }
      })
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
