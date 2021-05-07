<template>
  <VForm
    :model="dataValue"
    class="row"
    @submit.prevent
  >
    <FormItem
      v-for="variable in variables"
      :key="variable.name"
      :label="variable.display_name"
      class="col-6 col-lg-2 col-md-4 col-sm-4 mb-0 px-1"
    >
      <VariableInput
        v-model="dataValue[variable.name]"
        :variable="variable"
        @select="$emit('submit')"
        @enter="$emit('submit')"
        @update:model-value="$emit('update:data', dataValue)"
      />
    </FormItem>
  </VForm>
</template>

<script>
import VariableInput from './variable_input'

export default {
  name: 'VariablesForm',
  components: {
    VariableInput
  },
  props: {
    data: {
      type: Object,
      required: false,
      default: () => ({})
    },
    variables: {
      type: Array,
      required: true
    }
  },
  emits: ['update:data', 'submit'],
  data () {
    return {
      dataValue: { ...this.data }
    }
  },
  watch: {
    data (value) {
      this.dataValue = { ...value }
    }
  }
}
</script>

<style lang="scss" scoped>
:deep(.ivu-form-item-label) {
  padding-bottom: 5px;
}
</style>
