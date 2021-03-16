<template>
  <Layout>
    <AppHeader />
    <RouterView />
  </Layout>
</template>

<script>
import AppHeader from 'navigation/components/header'

export default {
  name: 'App',
  components: {
    AppHeader
  },
  computed: {
  },
  mounted () {
  }
}
</script>

<style lang="scss">
</style>
