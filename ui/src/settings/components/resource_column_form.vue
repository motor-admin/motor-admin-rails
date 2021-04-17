<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataColumn"
    >
      <FormItem
        label="Name"
        prop="display_name"
      >
        <VInput v-model="dataColumn.display_name" />
      </FormItem>

      <FormItem
        label="Visibility"
        prop="access_type"
      >
        <MSelect
          v-model="dataColumn.access_type"
          :options="accessTypes"
        />
      </FormItem>
      <FormItem
        v-if="dataColumn.access_type !== 'hidden'"
        label="Type"
        prop="column_type"
      >
        <MSelect
          v-model="dataColumn.column_type"
          :options="columnTypes"
        />
      </FormItem>
      <FormItem
        v-if="['read_write', 'write_only'].includes(dataColumn.access_type)"
        label="Default value"
        prop="default_value"
      >
        <FormInput
          v-model="dataColumn.default_value"
          :column="dataColumn"
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
        :loading="isLoading"
        @click="submit"
      >
        Save
      </VButton>
    </div>
  </div>
</template>

<script>
import FormInput from 'data_forms/components/input'
import Validators from 'utils/scripts/validators'
import { underscore } from 'utils/scripts/string'

export default {
  name: 'ResourceColumnForm',
  components: { FormInput },
  props: {
    column: {
      type: Object,
      required: true
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['cancel', 'submit', 'remove'],
  data () {
    return {
      isLoading: false,
      dataColumn: {}
    }
  },
  computed: {
    rules () {
      const rules = {
        display_name: [{ required: true }]
      }

      if (this.dataColumn.column_type === 'json') {
        rules.default_value = [{ validator: Validators.json }]
      }

      return rules
    },
    columnTypes () {
      return [
        { label: 'Text', value: 'string' },
        { label: 'Integer', value: 'integer' },
        { label: 'Decimal', value: 'float' },
        { label: 'Date and Time', value: 'datetime' },
        { label: 'Date', value: 'date' },
        { label: 'Boolean', value: 'boolean' },
        { label: 'File', value: 'file' },
        { label: 'JSON', value: 'json' }
      ]
    },
    accessTypes () {
      return [
        { label: 'Read-Write', value: 'read_write' },
        { label: 'Read-Only', value: 'read_only' },
        { label: 'Write-Only', value: 'write_only' },
        { label: 'Hidden', value: 'hidden' }
      ]
    }
  },
  watch: {
    'dataColumn.column_type' (value) {
      if (value !== this.column.column_type) {
        this.dataColumn.default_value = null
      } else if (this.column.default_value && typeof this.column.default_value === 'object') {
        this.dataColumn.default_value = JSON.stringify(this.column.default_value, null, '  ')
      } else {
        this.dataColumn.default_value = JSON.parse(JSON.stringify(this.column.default_value) || 'null')
      }
    }
  },
  created () {
    this.dataColumn = this.normalizeDataColumn()
  },
  methods: {
    normalizeDataColumn (column) {
      const dataColumn = JSON.parse(JSON.stringify(this.column))

      if (dataColumn.default_value && typeof dataColumn.default_value === 'object') {
        dataColumn.default_value = JSON.stringify(dataColumn.default_value, null, '  ')
      }

      if (!this.columnTypes.find((type) => type.value === this.column.column_type)) {
        dataColumn.column_type = 'string'
      }

      return dataColumn
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          if (!this.dataColumn.name) {
            this.dataColumn.name = underscore(this.dataColumn.display_name)
          }

          this.$emit('submit', this.dataColumn)
        }
      })
    }
  }
}
</script>
