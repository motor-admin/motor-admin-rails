<template>
  <Layout>
    <AppHeader ref="header" />

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
    document.addEventListener('keydown', (e) => {
      if ((e.ctrlKey || e.metaKey) && e.keyCode === 80) {
        e.preventDefault()

        this.$refs.header.openSearch()

        return false
      }
    })
  }
}
</script>

<style lang="scss">
</style>
