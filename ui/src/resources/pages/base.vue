<template>
  <ResourceTable :resource-name="resourceName" />
</template>

<script>
import ResourceTable from '../components/table'
import ResourceInfo from '../components/info'

export default {
  name: 'ResourcesBase',
  components: {
    ResourceTable,
    ResourceInfo
  },
  data () {
    return {}
  },
  computed: {
    resourceName () {
      return this.$route.params.fragments[0]
    }
  },
  methods: {
  }
}
</script>
