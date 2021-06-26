<template>
  <div class="trix-container">
    <trix-editor
      ref="trix"
      :contenteditable="!disabledEditor"
      class="richtext trix-content ivu-input"
      :input="computedId"
      :placeholder="placeholder"
      data-direct-upload-url="/rails/active_storage/direct_uploads"
      data-blob-url-template="/rails/active_storage/blobs/redirect/:signed_id/:filename"
      @trix-change="handleContentChange"
      @trix-file-accept="emitFileAccept"
      @trix-attachment-add="emitAttachmentAdd"
      @trix-attachment-remove="emitAttachmentRemove"
      @trix-selection-change="emitSelectionChange"
      @trix-initialize="handleInitialize"
      @trix-focus="processTrixFocus"
      @trix-blur="processTrixBlur"
    />
    <input
      :id="computedId"
      type="hidden"
      :name="inputName"
      :value="editorContent"
    >
  </div>
</template>

<script>
import Trix from 'trix'
import 'trix/dist/trix.css'
import { AttachmentUpload } from '@rails/actiontext/app/javascript/actiontext/attachment_upload'

export default {
  name: 'VueTrix',
  props: {
    disabledEditor: {
      type: Boolean,
      required: false,
      default: false
    },
    inputId: {
      type: String,
      required: false,
      default: ''
    },
    inputName: {
      type: String,
      required: false,
      default: 'content'
    },
    placeholder: {
      type: String,
      required: false,
      default: ''
    },
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    localStorage: {
      type: Boolean,
      required: false,
      default: false
    },
    autofocus: {
      type: Boolean,
      required: false,
      default: false
    },
    config: {
      type: Object,
      required: false,
      default: () => ({})
    }
  },
  emits: [
    'trix-attachment-add',
    'trix-attachment-remove',
    'trix-attachment-add',
    'trix-file-accept',
    'trix-initialize',
    'trix-selection-change',
    'trix-focus',
    'trix-blur',
    'trix-initialize',
    'update:modelValue'
  ],
  data () {
    return {
      editorContent: this.modelValue,
      isActived: null
    }
  },
  computed: {
    generateId () {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, c => {
        const r = Math.random() * 16 | 0
        const v = c === 'x' ? r : (r & 0x3 | 0x8)
        return v.toString(16)
      })
    },
    computedId () {
      return this.inputId || this.generateId
    },
    isDisabled () {
      return this.disabledEditor
    }
  },
  watch: {
    modelValue () {
      if (this.modelValue !== this.editorContent) {
        this.reloadEditorContent(this.modelValue)

        this.editorContent = this.modelValue
      }
    },
    editorContent () {
      if (this.localStorage) {
        localStorage.setItem(
          this.storageId('VueTrix'),
          JSON.stringify(this.$refs.trix.editor)
        )
      }
      this.$emit('update:modelValue', this.editorContent)
    },
    isDisabled (value) {
      this.decorateDisabledEditor(value)
    }
  },
  mounted () {
    this.overrideConfig(this.config)
    this.decorateDisabledEditor(this.disabledEditor)
    this.$nextTick(() => {
      if (this.localStorage) {
        const savedValue = localStorage.getItem(this.storageId('VueTrix'))
        if (savedValue && !this.modelValue) {
          this.$refs.trix.editor.loadJSON(JSON.parse(savedValue))
        }
      }
    })
  },
  methods: {
    emitAttachmentAdd (event) {
      const { attachment, target } = event

      if (attachment.file) {
        const upload = new AttachmentUpload(attachment, target)

        upload.start()
      }

      this.$emit('trix-attachment-add', event)
    },
    emitAttachmentRemove (file) {
      this.$emit('trix-attachment-remove', file)
    },
    emitHandleFile (file) {
      this.$emit('trix-attachment-add', file)
    },
    emitFileAccept (file) {
      this.$emit('trix-file-accept', file)
    },
    emitInitialize (editor) {
      this.$emit('trix-initialize', this.$refs.trix.editor, event)
    },
    emitSelectionChange (event) {
      this.$emit('trix-selection-change', this.$refs.trix.editor, event)
    },
    processTrixFocus (event) {
      if (this.$refs.trix) {
        this.isActived = true
        this.$emit('trix-focus', this.$refs.trix.editor, event)
      }
    },
    processTrixBlur (event) {
      if (this.$refs.trix) {
        this.isActived = false
        this.$emit('trix-blur', this.$refs.trix.editor, event)
      }
    },
    handleContentChange (event) {
      this.editorContent = event.srcElement ? event.srcElement.value : event.target.value
      this.$emit('update:modelValue', this.editorContent)
    },
    handleInitialize (event) {
      if (this.autofocus) {
        this.$refs.trix.editor.setSelectedRange(0)
      }

      this.$emit('trix-initialize', this.emitInitialize)
    },
    storageId (component) {
      if (this.inputId) {
        return `${component}.${this.inputId}.content`
      } else {
        return `${component}.content`
      }
    },
    reloadEditorContent (newContent) {
      this.$refs.trix.editor.loadHTML(newContent)

      this.$refs.trix.editor.setSelectedRange(this.getContentEndPosition())
    },
    getContentEndPosition () {
      return this.$refs.trix.editor.getDocument().toString().length - 1
    },
    decorateDisabledEditor (editorState) {
      if (editorState) {
        this.$refs.trix.toolbarElement.style['pointer-events'] = 'none'
        this.$refs.trix.contentEditable = false
        this.$refs.trix.style.background = '#e9ecef'
      } else {
        this.$refs.trix.toolbarElement.style['pointer-events'] = 'unset'
        this.$refs.trix.style['pointer-events'] = 'unset'
        this.$refs.trix.style.background = 'transparent'
      }
    },
    overrideConfig (config) {
      Trix.config = Object.assign(Trix.config, config)
    }
  }
}
</script>

<style lang="scss">
@import 'utils/styles/variables';

.trix-container {
  max-width: 100%;
  height: auto;

  .ivu-input {
    height: auto;
  }

  .trix-button-group {
    background-color: white;
  }
  .trix-content {
    background-color: white;
  }

  trix-editor {
    border: 1px solid $border-color-base;

  }

  .trix-button-group {
    border: 1px solid $border-color-base !important;

    .trix-button {
      border-bottom: 0 !important
    }
  }
}
</style>
