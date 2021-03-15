<template>
  <Layout>
    <AppHeader />
    <Layout
      :has-sider="true"
      :style="{ height: 'calc(100vh - 64px)' }"
    >
      <Sider
        :style="{ background: '#fff', maxHeight: 'calc(100vh - 64px)', overflowY: 'scroll' }"
      >
        <ResourcesMenu
          :resources="schema"
          :active-name="$route.params.fragments[0]"
          :style="{ minHeight: '100%' }"
        />
      </Sider>
      <Layout>
        <RouterView />
      </Layout>
    </Layout>
  </Layout>
</template>

<script>
import { schema } from 'utils/scripts/schema'
import AppHeader from 'navigation/components/header'
import ResourcesMenu from 'navigation/components/resources'

export default {
  name: 'App',
  components: {
    AppHeader,
    ResourcesMenu
  },
  computed: {
    schema () {
      return schema
    }
  },
  mounted () {
  }
}
</script>

<style lang="scss">
</style>
