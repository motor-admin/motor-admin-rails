<template>
  <Layout>
    <AppHeader />
    <Layout
      :has-sider="true"
      :style="{ height: 'calc(100vh - 64px)' }"
    >
      <Sider
        :style="{ background: '#fff' }"
      >
        <ResourcesMenu
          :resources="schema"
          :active-name="$route.params.fragments[0]"
          :style="{ maxHeight: 'calc(100vh - 64px)', overflowY: 'scroll', height: '100%' }"
        />
      </Sider>
      <Layout>
        <AppBreadcrumbs :style="{ margin: '14px 10px' }" />
        <Content>
          <RouterView />
        </Content>
      </Layout>
    </Layout>
  </Layout>
</template>

<script>
import store from 'store'
import AppHeader from 'navigation/components/header'
import AppBreadcrumbs from 'navigation/components/breadcrumbs'
import ResourcesMenu from 'navigation/components/resources'

export default {
  name: 'App',
  components: {
    AppHeader,
    AppBreadcrumbs,
    ResourcesMenu
  },
  computed: {
    schema () {
      return store.getters.schema
    }
  },
  mounted () {
  }
}
</script>

<style lang="scss">
</style>
