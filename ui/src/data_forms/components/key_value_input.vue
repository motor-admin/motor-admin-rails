<template>
  <div class="w-100 d-inline-block">
    <div
      v-for="(item, index) in value"
      :key="index"
      class="my-2 d-flex"
    >
      <VInput
        v-model="item.key"
        class="w-50 me-1"
        placeholder="Key"
        @update:model-value="emitUpdate"
      />
      <VInput
        v-model="item.value"
        class="w-50 mx-1"
        placeholder="Value"
        @update:model-value="emitUpdate"
      />
      <VButton
        icon="md-trash"
        class="ms-1"
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
  </div>
</template>

<script>
export default {
  name: 'ListInput',
  props: {
    modelValue: {
      type: Array,
      required: false,
      default: () => ([])
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
    emitUpdate (value) {
      this.$emit('update:modelValue', [...this.value])
    },
    removeItem (index) {
      this.value.splice(index, 1)

      this.emitUpdate()

      if (!this.value.length) {
        this.addNew()
      }
    },
    addNew () {
      this.value.push({ key: '', value: '' })
    }
  }
}
</script>
