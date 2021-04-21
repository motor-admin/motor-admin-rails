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
      class="col-6 col-lg-2 col-md-4 col-sm-4 mb-0"
    >
      <VInput
        v-model="dataValue[variable.name]"
        @update:model-value="$emit('update:data', dataValue)"
      />
    </FormItem>
  </VForm>
</template>

<script>
export default {
  name: 'VariablesForm',
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
  emits: ['update:data'],
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
