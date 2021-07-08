<template>
  <div
    v-for="(item, index) in value"
    :key="index"
    class="mb-2 d-flex"
  >
    <FormInput
      v-model="value[index]"
      :column="column"
      :form-data="formData"
      class="me-2 w-100"
      @update:model-value="emitUpdate"
    />
    <VButton
      icon="md-trash"
      @click="removeItem(index)"
    />
  </div>
  <VButton
    long
    icon="md-add"
    @click="addNew"
  >
    {{ i18n['add'] }}
  </VButton>
</template>

<script>
import FormInput from './input'

export default {
  name: 'ListInput',
  components: {
    FormInput
  },
  props: {
    modelValue: {
      type: Array,
      required: false,
      default: () => []
    },
    formData: {
      type: Object,
      required: false,
      default: () => ({})
    },
    column: {
      type: Object,
      required: true
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      value: [...(this.modelValue || [])]
    }
  },
  mounted () {
    if (!this.value.length) {
      this.addNew()
    }
  },
  methods: {
    emitUpdate () {
      const value = this.value.filter((v) => v !== '')

      this.$emit('update:modelValue', value)
    },
    removeItem (index) {
      this.value.splice(index, 1)

      this.emitUpdate()

      if (!this.value.length) {
        this.addNew()
      }
    },
    addNew () {
      this.value.push('')
    }
  }
}
</script>
