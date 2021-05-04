<template>
  <PrismEditor
    v-model="dataValue"
    class="code-editor"
    :highlight="highlighter"
    line-numbers
    @click="focusEditor"
  />
</template>

<script>
import { PrismEditor } from 'vue-prism-editor/packages/vue-prism-editor/src/Editor'
import { highlight, languages } from 'prismjs/components/prism-core'
import 'prismjs/components/prism-sql'
import 'prismjs/components/prism-markup'
import 'prismjs/components/prism-markdown'
import throttle from 'view3/src/utils/throttle'

import 'vue-prism-editor/packages/vue-prism-editor/src/styles.css'
import 'prismjs/themes/prism.css'

export default {
  name: 'CodeEditor',
  components: {
    PrismEditor
  },
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    language: {
      type: String,
      required: true
    }
  },
  emits: ['update:modelValue', 'run'],
  data () {
    return {
      dataValue: ''
    }
  },
  watch: {
    modelValue (value) {
      this.dataValue = value
    },
    dataValue (value) {
      this.$emit('update:modelValue', value)
    }
  },
  mounted () {
    this.dataValue = this.modelValue

    if (!this.dataValue) {
      this.focusEditor()
    }

    this.$el.querySelector('textarea').addEventListener('keydown', this.onCmdEnter)
  },
  beforeUnmount () {
    this.$el.querySelector('textarea').removeEventListener('keydown', this.onCmdEnter)
  },
  methods: {
    focusEditor () {
      this.$el.querySelector('textarea').focus()
    },
    onCmdEnter (e) {
      if (e.keyCode === 13 && e.metaKey) {
        this.$emit('run')
      }
    },
    highlighter (code) {
      return highlight(code, languages[this.language])
    }
  }
}
</script>

<style lang="scss">
.code-editor {
  background-color: rgb(237, 242, 245);
  font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
  font-size: 14px;
  padding: 10px 0;

  textarea:focus {
    outline-color: transparent;
    outline-style: none;
  }
}
</style>
