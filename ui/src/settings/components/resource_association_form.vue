<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataAssoc"
    >
      <div class="row">
        <div class="col-sm-12">
          <FormItem
            :label="i18n['name']"
            prop="display_name"
          >
            <VInput v-model="dataAssoc.display_name" />
          </FormItem>
        </div>
        <div class="col-sm-12">
          <FormItem
            :label="i18n['resource']"
            prop="model_name"
          >
            <MSelect
              v-model="dataAssoc.model_name"
              :value-key="'name'"
              :label-key="'display_name'"
              :with-deselect="false"
              :disabled="!!dataAssoc.options.through"
              :options="associationModels"
              :placeholder="i18n['select_resource_placeholder']"
              filterable
            />
          </FormItem>
        </div>
        <template v-if="dataAssoc.model_name !== 'active_storage/attachment'">
          <div class="col-sm-6 pe-sm-1">
            <FormItem
              :label="i18n['foreign_key']"
              prop="foreign_key"
            >
              <MSelect
                v-model="dataAssoc.foreign_key"
                :value-key="'name'"
                :disabled="!!dataAssoc.options.through"
                :label-key="'name'"
                :with-deselect="false"
                :options="associationColumns"
                filterable
              />
            </FormItem>
          </div>
          <div class="col-sm-6 ps-sm-1">
            <FormItem
              :label="i18n['primary_key']"
              prop="primary_key"
            >
              <MSelect
                v-model="dataAssoc.primary_key"
                :disabled="!!dataAssoc.options.through"
                :value-key="'name'"
                :label-key="'name'"
                :with-deselect="false"
                :options="resourceColumns"
                filterable
              />
            </FormItem>
          </div>
          <div class="col-sm-6 pe-sm-1">
            <FormItem
              :label="i18n['through']"
              prop="options.through"
            >
              <MSelect
                v-model="dataAssoc.options.through"
                :value-key="'name'"
                :label-key="'display_name'"
                :options="resourceReferences"
                filterable
                @update:model-value="$event ? '' : dataAssoc.options.source = null"
              />
            </FormItem>
          </div>
          <div class="col-sm-6 ps-sm-1">
            <FormItem
              :label="i18n['source']"
              prop="options.source"
            >
              <MSelect
                v-model="dataAssoc.options.source"
                :value-key="'name'"
                :label-key="'display_name'"
                :options="throughReferences"
                filterable
                @select="setAssociationKeys"
              />
            </FormItem>
          </div>
          <div
            class="col-sm-12 mb-2"
          >
            <Checkbox
              v-model="dataAssoc.polymorphic"
              @update:model-value="onPolymorphicChange"
            >
              {{ ' ' }}{{ i18n['polymorphic'] }}
            </Checkbox>
            <br>
            <Checkbox
              :model-value="!!dataAssoc.options.filters"
              @update:model-value="onFiltersToggle"
            >
              {{ ' ' }}{{ i18n['filter'] }}
            </Checkbox>
          </div>
        </template>
      </div>
      <Filters
        v-if="!!dataAssoc.options.filters && dataAssoc.model_name !== 'active_storage/attachment'"
        v-model:filters="dataAssoc.options.filters"
        :model="associationModel || throughModel"
      />
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
import Filters from 'data_resources/components/filters'
import { fieldRequiredMessage } from 'utils/scripts/i18n'
import { schema, modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'ResourceAssociationForm',
  components: {
    Filters
  },
  props: {
    association: {
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
      dataAssoc: {}
    }
  },
  computed: {
    rules () {
      const rules = {
        display_name: [{ required: true, message: fieldRequiredMessage('name') }],
        model_name: [{ required: true, message: fieldRequiredMessage('resource') }],
        primary_key: [{ required: true, message: fieldRequiredMessage('primary_key') }],
        foreign_key: [{ required: true, message: fieldRequiredMessage('foreign_key') }]
      }

      if (this.dataAssoc.options.through) {
        rules['options.source'] = [{ required: true, message: fieldRequiredMessage('source') }]
      }

      return rules
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    resourceColumns () {
      return this.model.columns.filter((c) => !c.virtual)
    },
    resourceReferences () {
      return [
        ...this.resourceColumns.map((column) => {
          return column.reference
        }).filter(Boolean),
        ...this.model.associations.filter((assoc) => assoc.display_name !== this.dataAssoc.display_name)
      ]
    },
    associationModel () {
      return modelNameMap[this.dataAssoc.model_name]
    },
    throughModel () {
      const reference = this.resourceReferences.find((c) => c.name === this.dataAssoc.options.through)

      return modelNameMap[reference?.model_name]
    },
    throughReferences () {
      if (this.throughModel) {
        return [
          ...this.throughModel.associations,
          ...this.throughModel.columns.map((column) => column.reference).filter(Boolean)
        ]
      } else {
        return []
      }
    },
    associationColumns () {
      if (this.dataAssoc.model_name) {
        return modelNameMap[this.dataAssoc.model_name].columns.filter((c) => c.column_source === 'table')
      } else {
        return []
      }
    },
    associationModels () {
      return schema
    },
    modelNameMap () {
      return modelNameMap
    }
  },
  created () {
    this.dataAssoc = JSON.parse(JSON.stringify(this.association))
  },
  methods: {
    setAssociationKeys (option) {
      if (option) {
        this.dataAssoc.primary_key = option.primary_key
        this.dataAssoc.foreign_key = option.foreign_key
        this.dataAssoc.model_name = option.model_name
      } else {
        this.dataAssoc.primary_key = null
        this.dataAssoc.foreign_key = null
        this.dataAssoc.model_name = null
      }
    },
    onFiltersToggle (value) {
      if (value) {
        this.dataAssoc.options.filters = []
      } else {
        delete this.dataAssoc.options.filters
      }
    },
    onPolymorphicChange (value) {
      if (value) {
        this.dataAssoc.model_name = null
        this.dataAssoc.primary_key = 'id'
      }
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', this.dataAssoc)
        }
      })
    }
  }
}
</script>
