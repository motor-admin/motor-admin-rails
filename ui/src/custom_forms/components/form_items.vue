<template>
  <div
    v-for="item in items"
    :key="item.name"
  >
    <GroupItem
      v-if="item.items"
      v-model:form-data="formData[item.name]"
      :item="item"
      :variables-data="variablesData"
      :prop-prefix="propPrefix ? `${propPrefix}.${item.name}` : item.name"
    />
    <FormItem
      v-else
      ref="formItem"
      :label="item.display_name"
      :rules="buildValidationRules(item)"
      :prop="propPrefix ? `${propPrefix}.${item.name}` : item.name"
    >
      <FormListInput
        v-if="item.is_array && ['file', 'json', 'textarea'].includes(item.field_type)"
        v-model="formData[item.name]"
        :column="item"
        :form-data="{ ...variablesData, ...formData }"
      />
      <FormInput
        v-else
        v-model="formData[item.name]"
        :column="item"
        :form-data="{ ...variablesData, ...formData }"
      />
    </FormItem>
  </div>
</template>

<script>
import FormListInput from 'data_forms/components/list_input'
import FormInput from 'data_forms/components/input'
import { buildDefaultValues } from '../scripts/utils'
import GroupItem from './group_item'
import { i18nDict } from 'utils/scripts/i18n'

export default {
  name: 'FormItems',
  components: {
    FormListInput,
    FormInput,
    GroupItem
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
  emits: ['update:form-data'],
  watch: {
    items: {
      deep: true,
      handler (value) {
        this.$emit('update:form-data', buildDefaultValues(this.items))
      }
    }
  },
  methods: {
    buildValidationRules (item) {
      return (item.validators || []).map((rule) => {
        return {
          ...rule,
          message: i18nDict.field_is_required.replace('%{field}', item.display_name)
        }
      })
    }
  }
}
</script>
