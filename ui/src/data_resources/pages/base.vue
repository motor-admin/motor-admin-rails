<template>
  <Layout
    :has-sider="true"
    :style="{ height: 'calc(var(--vh, 100vh) - 60px)', position: 'relative' }"
  >
    <Sider
      v-if="!isShowSiderScreen || fragments[0]"
      :model-value="isShowSiderScreen && isMenuSider"
      :collapsible="true"
      :collapsed-width="0"
      :style="{ background: '#fff', maxHeight: 'calc(var(--vh, 100vh) - 60px)' }"
    >
      <ResourcesMenu
        :resources="visibleResources"
        :active-name="activeNavigationName"
        :style="{ minHeight: '100%' }"
        @select="onMenuSelect"
      />
    </Sider>
    <SettingsMask
      v-if="!isShowSiderScreen && isShowSettings"
      style="width: 200px"
    />
    <Layout class="d-block">
      <template v-if="fragments && fragments.length">
        <template v-if="fragments.length > 1 || (isShowSiderScreen && fragments.length > 1) || widthLessThan('sm')">
          <Breadcrumbs
            :crumbs="crumbs"
            :with-menu="isShowSiderScreen"
            :style="{ padding: '14px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }"
            @click-menu="toggleResourcesMenu"
          />
          <Resource
            v-if="fragments.length > 1"
            :resource-name="resourceName"
            :resource-id="resourceId"
            :association-name="associationName"
          />
        </template>
        <ResourceTable
          v-if="fragments.length === 1"
          :key="resourceName"
          :height="`calc(var(--vh, 100vh) - ${widthLessThan('sm') ? '200px' : '148px'})`"
          :with-title="!widthLessThan('sm')"
          :with-menu="isShowSiderScreen && !widthLessThan('sm')"
          class="border-top border-md-0"
          :resource-name="resourceName"
          @click-menu="toggleResourcesMenu"
        />
      </template>
      <Home v-else />
    </Layout>
  </Layout>
</template>

<script>
import { schema, modelSlugMap, modelNameMap } from '../scripts/schema'
import Resource from '../components/resource'
import ResourceTable from '../components/table'
import Breadcrumbs from 'navigation/components/breadcrumbs'
import ResourcesMenu from 'navigation/components/resources'
import Home from 'navigation/components/home'
import { widthLessThan } from 'utils/scripts/dimensions'

import { breadcrumbStore } from 'navigation/scripts/breadcrumb_store'
import { isShowSettings, closeSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'

export default {
  name: 'ResourcesBase',
  components: {
    ResourceTable,
    Resource,
    Breadcrumbs,
    ResourcesMenu,
    Home,
    SettingsMask
  },
  data () {
    return {
      isMenuSider: false
    }
  },
  computed: {
    isShowSettings,
    model () {
      return modelNameMap[this.resourceName]
    },
    isShowSiderScreen () {
      return widthLessThan('xl')
    },
    activeNavigationName () {
      if (this.$route.query?.scope) {
        return this.fragments[0] + '.' + this.$route.query.scope
      } else {
        return this.fragments[0]
      }
    },
    visibleResources () {
      return schema.filter((model) => model.visible)
    },
    fragments () {
      return this.$route.params.fragments || []
    },
    normalizedFragments () {
      const normalizeFragments = []

      for (let i = 0; i < this.fragments.length; i++) {
        const association = (
          modelSlugMap[this.fragments[i - 2]]?.associations?.find((assoc) => assoc.slug === this.fragments[i]) ||
          normalizeFragments[i - 2]?.model?.associations?.find((assoc) => assoc.slug === this.fragments[i])
        )

        const model = modelSlugMap[this.fragments[i]] || modelNameMap[association?.model_name]

        const crumb = {
          fragment: this.fragments[i],
          association: association,
          model: model
        }

        normalizeFragments.push(crumb)
      }

      return normalizeFragments
    },
    associationName () {
      const last = this.fragments[this.fragments.length - 1]

      if (this.fragments.length > 2 && this.fragments.length % 2 === 1) {
        return last
      } else {
        return null
      }
    },
    resourceSlug () {
      if (this.associationName) {
        return this.fragments[this.fragments.length - 3]
      } else if (this.resourceId) {
        return this.fragments[this.fragments.length - 2]
      } else {
        return this.fragments[this.fragments.length - 1]
      }
    },
    resourceName () {
      if (modelSlugMap[this.resourceSlug]) {
        return modelSlugMap[this.resourceSlug].name
      } else {
        const normalizedFragments = this.normalizedFragments
        const association = normalizedFragments.find((assoc) => assoc.fragment === this.resourceSlug)

        return association.model.name
      }
    },
    crumbs () {
      const fragments = this.normalizedFragments
      const crumbs = []

      for (let i = 0; i < fragments.length; i++) {
        const crumb = {
          label: (
            fragments[i].association?.display_name ||
            fragments[i].model?.display_name ||
            ((!widthLessThan('sm') && breadcrumbStore[fragments[i - 1]?.model.name]) || {})[this.fragments[i]] ||
            `${this.fragments[i].match(/^\d+$/) ? '#' : ''}${this.fragments[i]}`
          )
        }

        if ((i - 1) !== fragments.length) {
          crumb.to = { name: 'resources', params: { fragments: this.fragments.slice(0, i + 1) } }
        }

        if (fragments.length === 1 && this.$route.query?.scope) {
          const scope = fragments[0].model.scopes.find((s) => s.name === this.$route.query.scope)
          crumb.label = `${crumb.label} (${scope.display_name})`
          crumb.to.query ||= {}
          crumb.to.query.scope = scope.name
        }

        crumbs.push(crumb)
      }

      return crumbs
    },
    resourceId () {
      const index = this.associationName ? 2 : 1
      const last = this.fragments[this.fragments.length - index]

      if (last && this.fragments.length > 1) {
        return last
      } else {
        return null
      }
    }
  },
  watch: {
    '$route' (to, from) {
      if (to.name === 'home') {
        closeSettings()
      }
    },
    isShowSiderScreen () {
      this.isMenuSider = this.isShowSiderScreen
    }
  },
  created () {
    this.isMenuSider = this.isShowSiderScreen
  },
  methods: {
    widthLessThan,
    onMenuSelect (value) {
      if (modelSlugMap[value]?.scopes?.find((s) => s.visible)) {
        if (this.fragments[0] === value) {
          this.toggleResourcesMenu()
        }
      } else {
        this.toggleResourcesMenu()
      }
    },
    toggleResourcesMenu () {
      this.isMenuSider = !this.isMenuSider
    }
  }
}
</script>

<style lang="scss" scoped>
:deep(.ivu-layout-sider-trigger) {
  display: none;
}

.ivu-card-body {
  line-break: normal;
}
</style>
