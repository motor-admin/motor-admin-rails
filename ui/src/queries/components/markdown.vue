<template>
  <div
    :class="isNoData ? 'd-flex align-items-center justify-content-center' : 'bg-white'"
    class="markdown"
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
      if (!this.isNoData) {
        return DOMPurify.sanitize(marked(this.mustacheRendered))
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

<style lang="scss">
.markdown {
  h6, h5, h4, h3, h2, h1 {
    margin-top: 0;
    margin-bottom: 0.5rem;
    font-weight: 500;
    line-height: 1.2;
  }

  hr {
    margin: 1rem 0;
    color: inherit;
    background-color: currentColor;
    border: 0;
    opacity: 0.25;
  }

  hr:not([size]) {
    height: 1px;
  }

  p {
    margin-top: 0;
    margin-bottom: 1rem;
  }

  address {
    margin-bottom: 1rem;
    font-style: normal;
    line-height: inherit;
  }

  ol,
  ul {
    padding-left: 2rem;
  }

  ol,
  ul,
  dl {
    margin-top: 0;
    margin-bottom: 1rem;
  }

  ol ol,
  ul ul,
  ol ul,
  ul ol {
    margin-bottom: 0;
  }

  dt {
    font-weight: 700;
  }

  dd {
    margin-bottom: 0.5rem;
    margin-left: 0;
  }

  blockquote{
    padding: 5px 5px 3px 10px;
    line-height: 1.5;
    border-left: 4px solid #ddd;
    margin-bottom: 20px;
    color: #666;
    font-size: 14px;
  }

  b,
  strong {
    font-weight: bolder;
  }

  small {
    font-size: 0.875em;
  }

  mark {
    padding: 0.2em;
    background-color: #fcf8e3;
  }

  sub,
  sup {
    position: relative;
    font-size: 0.75em;
    line-height: 0;
    vertical-align: baseline;
  }

  sub {
    bottom: -0.25em;
  }

  sup {
    top: -0.5em;
  }

  pre,
  code,
  kbd,
  samp {
    font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
    font-size: 1em;
    direction: ltr /* rtl:ignore */;
    unicode-bidi: bidi-override;
  }

  pre {
    display: block;
    margin-top: 0;
    margin-bottom: 1rem;
    overflow: auto;
    font-size: 0.875em;
    padding: 9.5px;
    margin: 0 0 10px;
    line-height: 1.42857143;
    color: #333;
    word-break: break-all;
    word-wrap: break-word;
    background-color: #f5f5f5;
    border: 1px solid #ccc;
    border-radius: 4px;
  }

  pre code {
    font-size: inherit;
    color: inherit;
    word-break: normal;
  }

  code {
    font-size: 0.875em;
    color: #d63384;
    word-wrap: break-word;
  }

  a > code {
    color: inherit;
  }

  kbd {
    padding: 0.2rem 0.4rem;
    font-size: 0.875em;
    color: #fff;
    background-color: #212529;
    border-radius: 0.2rem;
  }

  kbd kbd {
    padding: 0;
    font-size: 1em;
    font-weight: 700;
  }

  figure {
    margin: 0 0 1rem;
  }

  img,
  svg {
    vertical-align: middle;
  }

  table {
    caption-side: bottom;
    border-collapse: collapse;
  }

  caption {
    padding-top: 0.5rem;
    padding-bottom: 0.5rem;
    color: #6c757d;
    text-align: left;
  }

  th {
    text-align: inherit;
    text-align: -webkit-match-parent;
  }

  thead,
  tbody,
  tfoot,
  tr,
  td,
  th {
    border-color: inherit;
    border-style: solid;
    border-width: 0;
  }

  label {
    display: inline-block;
  }

  table {
    margin-bottom: 1rem;
    vertical-align: top;
    border-color: #dee2e6;
  }

  table > :not(caption) > * > * {
    padding: 0.5rem 0.5rem;
    border-bottom-width: 1px;
  }

  table > tbody {
    vertical-align: inherit;
  }

  table > thead {
    vertical-align: bottom;
  }
}
</style>
