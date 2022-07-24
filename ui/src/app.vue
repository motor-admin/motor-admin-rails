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
import { windowHeight } from 'utils/scripts/dimensions'

export default {
  name: 'App',
  components: {
    AppHeader
  },
  computed: {
    windowHeight () {
      return windowHeight.value
    }
  },
  watch: {
    windowHeight () {
      this.setVh()
    }
  },
  mounted () {
    document.addEventListener('keydown', this.processKey)

    this.setVh()
    this.maybeShowWelcomeModal()
  },
  methods: {
    setVh () {
      document.documentElement.style.setProperty('--vh', `${windowHeight.value}px`)
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
      if ((event.ctrlKey || event.metaKey) && event.keyCode === 75) {
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
