<template>
  <component
    :is="tag"
    :contenteditable="contenteditable"
    class="cursor-text"
    @input="updateModelValue"
    @blur="onFocusLost"
  >
    {{ value }}
  </component>
</template>

<script>
export default {
  name: 'Contenteditable',
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    tag: {
      type: String,
      required: false,
      default: 'p'
    },
    contenteditable: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      value: this.modelValue
    }
  },
  methods: {
    updateModelValue (event) {
      this.$emit('update:modelValue', event.target.innerText.trim())
    },
    onFocusLost () {
      if (!this.modelValue || this.modelValue.match(/^\s+$/)) {
        this.$emit('update:modelValue', this.value)
        this.$el.innerHTML = this.value
      } else {
        this.value = this.modelValue
      }
    }
  }
}
</script>
