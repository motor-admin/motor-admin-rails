<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataColumn"
    >
      <FormItem
        :label="i18n['name']"
        prop="display_name"
      >
        <VInput v-model="dataColumn.display_name" />
      </FormItem>

      <div class="row">
        <div :class="dataColumn.access_type !== 'hidden' ? 'col-sm-6 pe-sm-1' : 'col-12'">
          <FormItem
            :label="i18n['visibility']"
            prop="access_type"
          >
            <MSelect
              v-model="dataColumn.access_type"
              :with-deselect="false"
              :options="accessTypes"
            />
          </FormItem>
        </div>
        <div
          v-if="dataColumn.access_type !== 'hidden'"
          class="col-sm-6 ps-sm-1"
        >
          <FormItem
            :label="i18n['type']"
            prop="column_type"
          >
            <MSelect
              v-model="dataColumn.column_type"
              :options="columnTypes"
              filterable
              :with-deselect="false"
              :disabled="dataColumn.reference?.virtual === false"
              @update:model-value="assignDefaultData"
            />
          </FormItem>
        </div>
      </div>
      <div
        v-if="dataColumn.access_type !== 'hidden' && ['currency'].includes(dataColumn.column_type)"
        class="row"
      >
        <div class="col-sm-6 pe-sm-1">
          <FormItem
            :label="i18n['label']"
            prop="format.currency"
          >
            <CurrencySelect
              v-model="dataColumn.format.currency"
            />
          </FormItem>
        </div>
        <div class="col-sm-6 ps-sm-1">
          <FormItem
            :label="i18n['base']"
            prop="format.currency_base"
          >
            <MSelect
              v-model="dataColumn.format.currency_base"
              :with-deselect="false"
              :options="currencyBaseOptions"
            />
          </FormItem>
        </div>
      </div>
      <FormItem
        v-if="['association'].includes(dataColumn.column_type)"
        :label="i18n['association']"
        prop="format.association"
      >
        <MSelect
          v-model="dataColumn.format.association_name"
          :with-deselect="false"
          label-key="display_name"
          value-key="name"
          :options="model.associations"
        />
      </FormItem>
      <ReferenceForm
        v-if="dataColumn.access_type !== 'hidden' && ['reference'].includes(dataColumn.column_type) && dataColumn.reference"
        :resource-name="resourceName"
        :reference="dataColumn.reference"
      />
      <FormItem
        v-if="dataColumn.column_type === 'tag'"
        :label="i18n['select_options']"
        prop="format.select_options"
      >
        <OptionsInput
          v-model="dataColumn.format.select_options"
          :options-text="selectedOptionsText"
        />
        <div class="text-center">
          <VButton
            type="text"
            @click="loadSelectOptions"
          >
            {{ i18n.load_existing_options_from_database }}
          </VButton>
        </div>
      </FormItem>
      <FormItem
        v-if="dataColumn.column_type === 'select'"
        :label="i18n['select_query']"
        prop="format.select_query_id"
      >
        <QuerySelect v-model="dataColumn.format.select_query_id" />
      </FormItem>
      <FormItem
        v-if="dataColumn.column_type === 'link'"
        :label="i18n['link_text']"
        prop="format.link_text"
      >
        <VInput
          v-model="dataColumn.format.link_text"
        />
      </FormItem>
      <FormItem
        v-if="['tag'].includes(dataColumn.column_type)"
        :label="i18n['split_tags_by']"
        prop="format.split_tags_by"
      >
        <MSelect
          v-model="dataColumn.format.split_tags_by"
          :options="splitTagOptions"
        />
      </FormItem>
      <FormItem
        :label="i18n['description']"
        prop="description"
      >
        <VInput
          v-model="dataColumn.description"
          type="textarea"
          :autosize="{minRows: 1, maxRows: 5}"
        />
      </FormItem>
      <FormItem
        v-if="['read_write', 'write_only'].includes(dataColumn.access_type) && !['image', 'file', 'audio', 'video'].includes(dataColumn.column_type) && dataColumn.reference?.model_name !== 'active_storage/attachment'"
        :label="i18n['default_value']"
        prop="default_value"
      >
        <FormInput
          v-model="dataColumn.default_value"
          :column="dataColumn"
        />
      </FormItem>
      <Checkbox
        v-if="['read_write', 'write_only'].includes(dataColumn.access_type) && !dataColumn.reference && !['association'].includes(dataColumn.column_type)"
        :model-value="!!customValidator"
        class="mb-3"
        @update:model-value="toggleCustomValidator"
      >
        {{ ' ' }} {{ i18n['validate'] }}
      </Checkbox>
      <FormItem
        v-if="customValidator"
        :label="i18n['validation_regexp']"
        :prop="`validators.${dataColumn.validators.length - 1}.format`"
        :rules="validatorRegexpRule"
      >
        <VInput
          v-model="customValidator.format"
        />
      </FormItem>
      <FormItem
        v-if="customValidator"
        :label="i18n['error_message']"
        :prop="`validators.${dataColumn.validators.length - 1}.message`"
        :rules="validatorMessageRule"
      >
        <VInput
          v-model="customValidator.message"
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
        :loading="isLoading"
        @click="submit"
      >
        {{ i18n['save'] }}
      </VButton>
    </div>
  </div>
</template>

<script>
import FormInput from 'data_forms/components/input'
import Validators from 'utils/scripts/validators'
import CurrencySelect from 'utils/components/currency_select'
import OptionsInput from 'utils/components/options_input'
import ReferenceForm from './resource_reference_form'
import QuerySelect from 'queries/components/select'
import { fieldRequiredMessage } from 'utils/scripts/i18n'
import { modelNameMap } from 'data_resources/scripts/schema'
import { underscore } from 'utils/scripts/string'
import api from 'api'

export default {
  name: 'ResourceColumnForm',
  components: {
    FormInput,
    CurrencySelect,
    OptionsInput,
    ReferenceForm,
    QuerySelect
  },
  props: {
    column: {
      type: Object,
      required: true
    },
    resourceName: {
      type: String,
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
      dataColumn: {},
      selectedOptionsText: ''
    }
  },
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    },
    rules () {
      const rules = {
        display_name: [{
          required: true,
          message: fieldRequiredMessage('name')
        }]
      }

      if (this.dataColumn.column_type === 'json') {
        rules.default_value = [{ validator: Validators.json, fullField: this.i18n.default_value }]
      }

      if (this.dataColumn.column_type === 'reference') {
        if (!this.dataColumn.reference?.polymorphic) {
          rules['reference.model_name'] = [{ required: true, message: fieldRequiredMessage('reference_resource') }]
        }

        rules['reference.foreign_key'] = [{ required: true, message: fieldRequiredMessage('foreign_key') }]
        rules['reference.primary_key'] = [{ required: true, message: fieldRequiredMessage('primary_key') }]
      }

      if (this.dataColumn.column_type === 'association') {
        rules['format.association_name'] = [{ required: true, message: fieldRequiredMessage('association') }]
      }

      return rules
    },
    validatorRegexpRule () {
      return [
        { required: true, message: fieldRequiredMessage('regexp') },
        { validator: Validators.regexp, fullField: this.i18n.regexp }
      ]
    },
    validatorMessageRule () {
      return [{ required: true, message: fieldRequiredMessage('message') }]
    },
    currencyBaseOptions () {
      return [
        { label: this.i18n.unit, value: 'unit' },
        { label: this.i18n.cents, value: 'cents' }
      ]
    },
    columnTypes () {
      return [
        { label: this.i18n.text, value: 'string' },
        { label: this.i18n.integer, value: 'integer' },
        { label: this.i18n.decimal, value: 'float' },
        { label: this.i18n.reference, value: 'reference' },
        { label: this.i18n.association, value: 'association' },
        { label: this.i18n.date_and_time, value: 'datetime' },
        { label: this.i18n.date, value: 'date' },
        { label: this.i18n.boolean, value: 'boolean' },
        { label: this.i18n.long_text, value: 'textarea' },
        { label: this.i18n.richtext, value: 'richtext' },
        { label: this.i18n.currency, value: 'currency' },
        { label: this.i18n.percentage, value: 'percentage' },
        { label: this.i18n.rating, value: 'rating' },
        { label: this.i18n.change, value: 'change' },
        { label: this.i18n.chart, value: 'chart' },
        { label: this.i18n.tag, value: 'tag' },
        { label: this.i18n.select, value: 'select' },
        { label: this.i18n.link, value: 'link' },
        { label: this.i18n.color, value: 'color' },
        { label: this.i18n.image, value: 'image' },
        { label: this.i18n.audio, value: 'audio' },
        { label: this.i18n.video, value: 'video' },
        { label: this.i18n.file, value: 'file' },
        { label: this.i18n.json, value: 'json' }
      ]
    },
    customValidator () {
      return this.dataColumn.validators.find((validator) => 'message' in validator)
    },
    accessTypes () {
      return [
        { label: this.i18n.read_write, value: 'read_write' },
        { label: this.i18n.read_only, value: 'read_only' },
        { label: this.i18n.write_only, value: 'write_only' },
        { label: this.i18n.hidden, value: 'hidden' }
      ]
    },
    splitTagOptions () {
      return [
        { label: this.i18n.semicolon, value: ';' },
        { label: this.i18n.comma, value: ',' },
        { label: this.i18n.hyphen, value: '-' },
        { label: this.i18n.slash, value: '/' }
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
    toggleCustomValidator () {
      if (this.customValidator) {
        this.dataColumn.validators = [...this.column.validators.filter((v) => !('message' in v))]
      } else {
        this.dataColumn.validators.push({ format: '', message: '' })
      }
    },
    assignDefaultData () {
      if (this.column.reference) {
        if (this.column.reference.virtual) {
          this.dataColumn.reference = null
        } else {
          this.dataColumn.reference = JSON.parse(JSON.stringify(this.column.reference))
        }
      }

      if (this.dataColumn.column_type === 'currency') {
        this.dataColumn.format.currency ||= 'USD'
        this.dataColumn.format.currency_base ||= 'unit'
      } else if (this.dataColumn.column_type === 'reference') {
        this.dataColumn.reference = {
          name: '',
          display_name: '',
          model_name: (modelNameMap[this.column.name] || modelNameMap[this.column.name.replace(/_id$/, '')])?.name,
          reference_type: this.column.virtual ? 'has_one' : 'belongs_to',
          foreign_key: this.column.virtual ? '' : this.column.name,
          primary_key: 'id',
          options: {},
          polymorphic: false,
          virtual: true
        }
      }
    },
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
    loadSelectOptions () {
      const sqlBody = `SELECT DISTINCT(${this.dataColumn.name}) FROM ${this.model.table_name}`

      api.post('run_queries', {
        sql_body: sqlBody,
        preferences: {
          database: this.model.name.includes('/') ? this.model.name.split('/')[0] : 'default'
        }
      }).then((result) => {
        this.dataColumn.format.select_options = result.data.data.flat().map((e) => e?.match && e.match(/^{.*}$/) ? e.split(/[{},]/) : e).flat().filter(Boolean)
        this.selectedOptionsText = Array(this.dataColumn.format.select_options).flat().join('\n')
      })
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          if (this.dataColumn.reference) {
            const idSuffixRegexp = new RegExp(`_${this.dataColumn.reference.primary_key}$`)

            if (this.dataColumn.reference.model_name === 'active_storage/attachment') {
              this.dataColumn.reference.name ||= underscore(this.dataColumn.display_name) + '_attachment'
            } else {
              this.dataColumn.reference.name ||= underscore(this.dataColumn.display_name).replace(idSuffixRegexp, '')
            }

            this.dataColumn.reference.display_name ||= this.dataColumn.display_name
          }

          this.$emit('submit', this.dataColumn)
        }
      })
    }
  }
}
</script>
