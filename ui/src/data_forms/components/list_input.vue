<template>
  <div
    v-for="(item, index) in value"
    :key="index"
    class="mb-2 d-flex"
  >
    <Input
      v-model="value[index]"
      :column="column"
      class="me-2"
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
    Add
  </VButton>
</template>

<script>
import Input from './input'

export default {
  name: 'ListInput',
  components: {
    Input
  },
  props: {
    modelValue: {
      type: Array,
      required: false,
      default: () => []
    },
    column: {
      type: Object,
      required: true
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      value: [...this.modelValue]
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
