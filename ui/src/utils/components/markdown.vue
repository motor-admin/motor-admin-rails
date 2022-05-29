<template>
  <div
    :class="isNoData && !withoutData ? 'd-flex align-items-center justify-content-center' : 'bg-white'"
    class="richtext"
    v-html="sanitizedHtml"
  />
</template>

<script>
import DOMPurify from 'dompurify'
import { marked } from 'marked'
import throttle from 'view3/src/utils/throttle'

import { Liquid } from 'liquidjs'

const liquidEngine = new Liquid()

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
    renderTemplate: {
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
      renderedTemplate: ''
    }
  },
  computed: {
    isNoData () {
      return !Object.keys(this.data).length
    },
    sanitizedHtml () {
      if (this.withoutData || !this.isNoData) {
        return DOMPurify.sanitize(marked(this.renderTemplate ? this.renderedTemplate : this.markdown))
      } else {
        return this.loading ? '' : 'No data'
      }
    }
  },
  watch: {
    markdown: throttle(function () {
      this.render()
    }, 500),
    data: throttle(function () {
      this.render()
    }, 500)
  },
  mounted () {
    this.render()
  },
  methods: {
    render () {
      liquidEngine.parseAndRender(this.markdown, this.data).then((result) => {
        this.renderedTemplate = result
      }).catch(() => {
      })
    }
  }
}
</script>
