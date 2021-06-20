<template>
  <div
    v-for="item in items"
    :key="item.name"
  >
    <GroupItem
      v-if="item.items"
      v-model:form-data="formData[item.name]"
      :item="item"
      :prop="propPrefix ? `${propPrefix}.${item.name}` : item.name"
    />
    <FormItem
      v-else
      ref="formItem"
      :label="item.display_name"
      :rules="item.validators"
      :prop="propPrefix ? `${propPrefix}.${item.name}` : item.name"
    >
      <FormInput
        v-model="formData[item.name]"
        :column="item"
        :form-data="formData"
      />
    </FormItem>
  </div>
</template>

<script>
import FormInput from 'data_forms/components/input'
import { buildDefaultValues } from '../scripts/utils'
import GroupItem from './group_item'

export default {
  name: 'FormItems',
  components: {
    FormInput,
    GroupItem
  },
  props: {
    formData: {
      type: Object,
      required: true
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
  }
}
</script>
