<template>
  <div
    v-for="item in items"
    :key="item.name"
  >
    <template v-if="checkConditions(item.conditions, mergedVariablesFormData)">
      <Markdown
        v-if="item.markdown"
        :markdown="item.markdown"
        :data="mergedVariablesFormData"
        :without-data="true"
      />
      <GroupItem
        v-else-if="item.items"
        v-model:form-data="formData[item.name]"
        :item="item"
        :variables-data="variablesData"
        :prop-prefix="propPrefix ? `${propPrefix}.${item.name}` : item.name"
      />
      <FormItem
        v-else
        ref="formItem"
        :label="interpolate(item.display_name, mergedVariablesFormData)"
        :rules="buildValidationRules(item)"
        :prop="propPrefix ? `${propPrefix}.${item.name}` : item.name"
      >
        <FormListInput
          v-if="item.is_array && ['json', 'textarea'].includes(item.field_type)"
          v-model="formData[item.name]"
          :column="item"
          :form-data="mergedVariablesFormData"
          @update:model-value="$emit('edit')"
        />
        <FormInput
          v-else
          v-model="formData[item.name]"
          :column="item"
          :form-data="mergedVariablesFormData"
          @update:model-value="$emit('edit')"
        />
      </FormItem>
    </template>
  </div>
</template>

<script>
import FormListInput from 'data_forms/components/list_input'
import FormInput from 'data_forms/components/input'
import Markdown from 'utils/components/markdown'
import { interpolate } from 'utils/scripts/string'
import { buildDefaultValues, checkConditions } from '../scripts/utils'
import GroupItem from './group_item'
import { buildColumnValidator } from 'data_resources/scripts/form_utils'

export default {
  name: 'FormItems',
  components: {
    FormListInput,
    FormInput,
    GroupItem,
    Markdown
  },
  props: {
    formData: {
      type: Object,
      required: true
    },
    variablesData: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propPrefix: {
      type: String,
      required: false,
      default: ''
    },
    items: {
      type: Array,
      required: true
    }
  },
  emits: ['update:form-data', 'edit'],
  computed: {
    mergedVariablesFormData () {
      return { ...this.variablesData, ...this.formData }
    }
  },
  watch: {
    items: {
      deep: true,
      handler (value) {
        this.$emit('update:form-data', buildDefaultValues(this.items))
      }
    }
  },
  methods: {
    checkConditions,
    interpolate,
    buildValidationRules (item) {
      return buildColumnValidator(item, {})
    }
  }
}
</script>
