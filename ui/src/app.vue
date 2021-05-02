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
    document.addEventListener('keydown', this.processKey)

    window.addEventListener('load', this.setVh)
    window.addEventListener('resize', this.setVh)
  },
  methods: {
    setVh () {
      const vh = window.innerHeight

      document.documentElement.style.setProperty('--vh', `${vh}px`)
    },
    processKey (event) {
      if ((event.ctrlKey || event.metaKey) && event.keyCode === 80) {
        event.preventDefault()

        this.$refs.header.openSearch()

        return false
      }
    }
  }
}
</script>

<style lang="scss">
</style>
