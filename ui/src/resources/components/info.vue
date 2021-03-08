<template>
  <div style="white-space: break-spaces">
    {{ resource }}
  </div>
</template>

<script>
import api from 'api'

export default {
  name: 'ResourceInfo',
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    }
  },
  data () {
    return {
      resource: {}
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    loadData () {
      api.get(`data/${this.resourceName}/${this.resourceId}`).then((result) => {
        this.resource = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
