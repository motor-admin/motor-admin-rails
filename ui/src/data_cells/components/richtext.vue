<template>
  <div
    class="richtext richtext-cell trix-content"
    v-html="truncate ? truncatedValue : safeHtml"
  />
</template>

<script>
import DOMPurify from 'dompurify'
import Trix from 'trix'
import { copyToClipboard } from '../mixins/copy_to_clipboard'

const MAX_LENGTH = 60 // chars

export default {
  name: 'RichtextCell',
  props: {
    value: {
      type: [String],
      required: false,
      default: ''
    },
    truncate: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  computed: {
    safeHtml () {
      if (this.value?.includes('data-trix-attachment')) {
        return Trix.DocumentView.render(Trix.Document.fromHTML(this.value)).innerHTML
      } else {
        return DOMPurify.sanitize(this.value)
      }
    },
    truncatedValue () {
      if (this.rawText.length > MAX_LENGTH) {
        return this.rawText.slice(0, MAX_LENGTH) + '...'
      } else {
        return this.rawText
      }
    },
    rawText () {
      return DOMPurify.sanitize(this.value, { ALLOWED_TAGS: [], KEEP_CONTENT: true })
    },
    popoverParams () {
      return {
        content: this.safeHtml,
        trigger: 'mouseenter',
        disabled: true, // !this.isTruncated,
        bodyStyle: {
          maxWidth: '350px',
          overflowY: 'auto',
          maxHeight: '200px',
          whiteSpace: 'pre-wrap',
          lineBreak: 'anywhere'
        }
      }
    }
  },
  mounted () {
    this.$el.querySelectorAll('.attachment__name').forEach((node) => {
      const attrsString = node.parentElement?.parentElement?.dataset?.trixAttachment

      if (attrsString) {
        const attrs = JSON.parse(attrsString)

        const img = document.createElement('a')

        img.href = attrs.url
        img.innerHTML = attrs.filename

        node.innerHTML = img.outerHTML
      }
    })
  },
  methods: {
    copyToClipboard
  }
}
</script>

<style lang="scss">
.richtext-cell {
  max-height: 250px;
  width: 100%;
  overflow-y: hidden;
  line-break: normal;

  &:hover {
    overflow-y: auto;
  }
}

.trix-content {
  .attachment-gallery {
    > action-text-attachment,
    > .attachment {
      flex: 1 0 33%;
      padding: 0 0.5em;
      max-width: 33%;
    }

    &.attachment-gallery--2,
    &.attachment-gallery--4 {
      > action-text-attachment,
      > .attachment {
        flex-basis: 50%;
        max-width: 50%;
      }
    }
  }

  action-text-attachment {
    .attachment {
      padding: 0 !important;
      max-width: 100% !important;
    }
  }
}

.richtext-no-padding {
  .richtext {
    padding: 0 !important
  }
}

.richtext-no-scroll {
  .richtext {
    overflow: initial !important
  }
}
</style>
