<template>
  <div class="row">
    <div class="col-sm-12">
      <FormItem
        :label="i18n['reference_resource']"
        prop="reference.model_name"
      >
        <MSelect
          v-model="reference.model_name"
          :value-key="'name'"
          :label-key="'display_name'"
          :with-deselect="false"
          :options="referenceModels"
          :disabled="reference.polymorphic || !!reference.options.through"
          :placeholder="i18n['select_resource_placeholder']"
          filterable
        />
      </FormItem>
    </div>
    <template v-if="reference.model_name !== 'active_storage/attachment'">
      <div class="col-sm-6 pe-sm-1">
        <FormItem
          :label="i18n['foreign_key']"
          prop="reference.foreign_key"
        >
          <MSelect
            v-model="reference.foreign_key"
            :value-key="'name'"
            :label-key="'name'"
            :with-deselect="false"
            :disabled="!!reference.options.through"
            :options="reference.reference_type === 'has_one' ? referenceColumns : resourceColumns"
            filterable
          />
        </FormItem>
      </div>
      <div class="col-sm-6 ps-sm-1">
        <FormItem
          :label="i18n['primary_key']"
          prop="reference.primary_key"
        >
          <MSelect
            v-model="reference.primary_key"
            :value-key="'name'"
            :label-key="'name'"
            :with-deselect="false"
            :disabled="reference.polymorphic || !!reference.options.through"
            :options="reference.reference_type === 'has_one' ? resourceColumns : referenceColumns"
            filterable
          />
        </FormItem>
      </div>
      <template v-if="reference.reference_type === 'has_one'">
        <div class="col-sm-6 pe-sm-1">
          <FormItem
            :label="i18n['through']"
            prop="reference.options.through"
          >
            <MSelect
              v-model="reference.options.through"
              :value-key="'name'"
              :label-key="'display_name'"
              :options="resourceReferences"
              filterable
            />
          </FormItem>
        </div>
        <div class="col-sm-6 ps-sm-1">
          <FormItem
            :label="i18n['source']"
            prop="reference.options.source"
          >
            <MSelect
              v-model="reference.options.source"
              :value-key="'name'"
              :label-key="'display_name'"
              :options="throughReferences"
              filterable
              @select="setReferenceKeys"
            />
          </FormItem>
        </div>
      </template>
      <div
        v-else
        class="col-sm-12"
      >
        <FormItem
          :label="i18n['polymorphic']"
          prop="reference.polymorphic"
        >
          <Checkbox
            v-model="reference.polymorphic"
            @update:model-value="onPolymorphicChange"
          />
        </FormItem>
      </div>
    </template>
  </div>
</template>

<script>
import { schema, modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'ResourceReferenceForm',
  props: {
    resourceName: {
      type: String,
      required: true
    },
    reference: {
      type: Object,
      required: true
    }
  },
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    },
    resourceColumns () {
      return this.model.columns.filter((c) => c.column_source === 'table')
    },
    resourceReferences () {
      return this.resourceColumns.map((column) => {
        return column.reference
      }).filter(Boolean)
    },
    throughReferences () {
      const reference = this.resourceReferences.find((c) => c.name === this.reference.options.through)

      if (reference) {
        return modelNameMap[reference.model_name].columns.map((column) => {
          return column.reference
        }).filter(Boolean)
      } else {
        return []
      }
    },
    referenceColumns () {
      if (this.reference.model_name) {
        return modelNameMap[this.reference.model_name].columns.filter((c) => c.column_source === 'table')
      } else {
        return []
      }
    },
    referenceModels () {
      return schema
    },
    modelNameMap () {
      return modelNameMap
    }
  },
  methods: {
    setReferenceKeys (option) {
      if (option) {
        this.reference.primary_key = option.primary_key
        this.reference.foreign_key = option.foreign_key
        this.reference.model_name = option.model_name
      } else {
        this.reference.primary_key = null
        this.reference.foreign_key = null
        this.reference.model_name = null
      }
    },
    onPolymorphicChange (value) {
      if (value) {
        this.reference.model_name = null
        this.reference.primary_key = 'id'
      }
    }
  }
}
</script>
