<template>
  <div>
    <CodeEditor
      v-model="dataValue"
      language="markdown"
      :variables="fields"
      style="height: 150px; line-height: 21px"
      @run="submit"
    />
    <Markdown
      :style="{ height: '150px', overflow: 'scroll' }"
      :markdown="dataValue"
      :render-template="false"
      :without-data="true"
    />
    <VButton
      size="large"
      long
      type="primary"
      class="mt-3"
      @click="submit"
    >
      {{ i18n['ok'] }}
    </VButton>
  </div>
</template>

<script>
import CodeEditor from 'utils/components/code_editor'
import Markdown from 'utils/components/markdown'

export default {
  name: 'TextForm',
  components: {
    CodeEditor,
    Markdown
  },
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    fields: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['submit'],
  data () {
    return {
      dataValue: ''
    }
  },
  created () {
    this.dataValue = this.modelValue
  },
  methods: {
    submit () {
      this.$emit('submit', this.dataValue)
    }
  }
}
</script>
