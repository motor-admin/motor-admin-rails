<template>
  <Layout>
    <AppHeader ref="header" />

    <RouterView />
  </Layout>
</template>

<script>
import Welcome from 'navigation/components/welcome'
import AppHeader from 'navigation/components/header'

import { currentUser } from 'navigation/scripts/user_store'

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

    this.maybeShowWelcomeModal()
  },
  methods: {
    setVh () {
      const vh = window.innerHeight

      document.documentElement.style.setProperty('--vh', `${vh}px`)
    },
    maybeShowWelcomeModal () {
      if (currentUser.showWelcome) {
        this.$Modal.open(Welcome, {
          onClose: () => {
            this.$Modal.remove()
          },
          onOpenGuides: () => {
            this.$Modal.remove()

            setTimeout(() => {
              this.$refs.header.openGuides()
            }, 350)
          }
        })

        currentUser.showWelcome = false
      }
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
