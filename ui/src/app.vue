<template>
  <div>
    <p>hello admin</p>
    <AppHeader />
    <RouterView />
  </div>
</template>

<script>
import AppHeader from 'navigation/components/header'

export default {
  name: 'App',
  components: {
    AppHeader
  }
}
</script>
