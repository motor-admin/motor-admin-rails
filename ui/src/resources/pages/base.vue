<template>
  <Layout
    :has-sider="true"
    :style="{ height: 'calc(100vh - 60px)' }"
  >
    <Sider
      :style="{ background: '#fff', maxHeight: 'calc(100vh - 60px)', overflowY: 'scroll' }"
    >
      <ResourcesMenu
        :resources="visibleResources"
        :active-name="fragments[0]"
        :style="{ minHeight: '100%' }"
      />
    </Sider>
    <Layout>
      <template v-if="fragments && fragments.length > 1">
        <Breadcrumbs
          :crumbs="crumbs"
          :style="{ margin: '14px 10px' }"
        />
        <Resource
          :resource-name="resourceName"
          :resource-id="resourceId"
          :association-name="associationName"
        />
      </template>
      <ResourceTable
        v-if="fragments.length === 1"
        :key="resourceName"
        :height="'calc(100vh - 146px)'"
        :with-title="true"
        :resource-name="resourceName"
      />
    </Layout>
  </Layout>
</template>

<script>
import { schema, modelSlugMap } from 'utils/scripts/schema'
import Resource from '../components/resource'
import ResourceTable from '../components/table'
import Breadcrumbs from 'navigation/components/breadcrumbs'
import ResourcesMenu from 'navigation/components/resources'

import { breadcrumbStore } from 'navigation/scripts/breadcrumb_store'

export default {
  name: 'ResourcesBase',
  components: {
    ResourceTable,
    Resource,
    Breadcrumbs,
    ResourcesMenu
  },
  computed: {
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

        const model = modelSlugMap[this.fragments[i]] || modelSlugMap[association?.model_slug]

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

      if (this.fragments.length > 2 && !last.match(/^\d+$/)) {
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
            (breadcrumbStore[fragments[i - 1]?.model.name] || {})[this.fragments[i]] ||
            `#${this.fragments[i]}`
          )
        }

        if ((i - 1) !== fragments.length) {
          crumb.to = { name: 'resources', params: { fragments: this.fragments.slice(0, i + 1) } }
        }

        crumbs.push(crumb)
      }

      return crumbs
    },
    resourceId () {
      const index = this.associationName ? 2 : 1
      const last = this.fragments[this.fragments.length - index]

      if (last && last.match(/^\d+$/)) {
        return last
      } else {
        return null
      }
    }
  }
}
</script>
