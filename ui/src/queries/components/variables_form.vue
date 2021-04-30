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
      <ResourceSelect
        v-if="isReference(variable.name)"
        v-model="dataValue[variable.name]"
        :resource-name="variable.name.replace(/_id$/, '')"
        @update:model-value="onResourceSelect"
      />
      <VInput
        v-else
        v-model="dataValue[variable.name]"
        @keydown.enter="$emit('submit')"
        @update:model-value="$emit('update:data', dataValue)"
      />
    </FormItem>
  </VForm>
</template>

<script>
import { modelNameMap } from 'data_resources/scripts/schema'
import ResourceSelect from 'data_resources/components/select'

export default {
  name: 'VariablesForm',
  components: {
    ResourceSelect
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
  },
  methods: {
    onResourceSelect () {
      this.$emit('update:data', this.dataValue)

      this.$nextTick(() => {
        this.$emit('submit')
      })
    },
    isReference (name) {
      return !!modelNameMap[name.replace(/_id$/, '')]
    }
  }
}
</script>
