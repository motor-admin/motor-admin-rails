<template>
  <div
    :class="isNoData && !withoutData ? 'd-flex align-items-center justify-content-center' : 'bg-white'"
  />
</template>

<script>
import throttle from 'view3/src/utils/throttle'
import { Liquid } from 'liquidjs'

const liquidEngine = new Liquid()

export default {
  name: 'QueryLiquid',
  props: {
    html: {
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
    renderHtml: {
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
  computed: {
    isNoData () {
      return !Object.keys(this.data).length
    }
  },
  watch: {
    html: throttle(function () {
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
      liquidEngine.parseAndRender(this.html, this.data).then((result) => {
        this.$el.innerHTML = result
      }).catch(() => {
      })
    }
  }
}
</script>
