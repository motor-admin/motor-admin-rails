<template>
  <div
    :class="isNoData && !withoutData ? 'd-flex align-items-center justify-content-center' : 'bg-white'"
    class="richtext"
    v-html="sanitizedHtml"
  />
</template>

<script>
import DOMPurify from 'dompurify'
import marked from 'marked'
import Mustache from 'mustache'
import throttle from 'view3/src/utils/throttle'
import { naiveMustache } from 'utils/scripts/string'

export default {
  name: 'QueryMarkdown',
  props: {
    markdown: {
      type: String,
      required: false,
      default: ''
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
    },
    withoutData: {
      type: Boolean,
      required: false,
      default: false
    },
    renderMustache: {
      type: Boolean,
      required: false,
      default: true
    },
    data: {
      type: Object,
      required: false,
      default: () => ({})
    }
  },
  data () {
    return {
      dataMarkdown: ''
    }
  },
  computed: {
    isNoData () {
      return !Object.keys(this.data).length
    },
    mustacheRendered () {
      try {
        return Mustache.render(this.dataMarkdown, this.data)
      } catch {
        return naiveMustache(this.dataMarkdown, this.data)
      }
    },
    sanitizedHtml () {
      if (this.withoutData || !this.isNoData) {
        return DOMPurify.sanitize(marked(this.renderMustache ? this.mustacheRendered : this.dataMarkdown))
      } else {
        return this.loading ? '' : 'No data'
      }
    }
  },
  watch: {
    markdown: throttle(function () {
      this.dataMarkdown = this.markdown
    }, 500)
  },
  created () {
    this.dataMarkdown = this.markdown
  }
}
</script>
