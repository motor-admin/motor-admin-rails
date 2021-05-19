<template>
  <component
    :is="tag"
    ref="contenteditable"
    :contenteditable="contenteditable"
    class="cursor-text"
    v-bind="$attrs"
    @input="updateModelValue"
    @click="isContentEditable = true"
    @blur="onFocusLost"
    @keydown.enter.prevent="$refs.contenteditable.blur()"
  >
    {{ value }}
  </component>
  <Icon
    v-if="withEditButton && !isContentEditable"
    type="md-create"
    class="contenteditable-edit-button ms-2 cursor-pointer"
    @click.stop="onEditClick"
  />
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
    },
    withEditButton: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['update:modelValue', 'change'],
  data () {
    return {
      value: this.modelValue,
      isContentEditable: false
    }
  },
  watch: {
    modelValue (value) {
      if (value.trim() !== this.$refs.contenteditable.innerText.trim()) {
        this.value = value
      }
    }
  },
  methods: {
    updateModelValue (event) {
      this.$emit('update:modelValue', event.target.innerText.trim())
    },
    onEditClick () {
      this.isContentEditable = true

      this.$nextTick(() => {
        this.$refs.contenteditable.focus()

        document.execCommand('selectAll', false, null)
        document.getSelection().collapseToEnd()
      })
    },
    onFocusLost () {
      this.isContentEditable = false

      if (this.value === this.modelValue) {
        return
      }

      if (!this.modelValue || this.modelValue.match(/^\s+$/)) {
        this.$emit('update:modelValue', this.value)
        this.$refs.contenteditable.innerHTML = this.value
      } else {
        this.value = this.modelValue

        this.$emit('change', this.value)
      }
    }
  }
}
</script>
