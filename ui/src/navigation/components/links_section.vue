<template>
  <div
    v-for="link in linksToRender"
    :key="link.name"
    class="col-12 col-md-6 col-lg-4 col-xl-3"
  >
    <component
      :is="link.is"
      :to="link.to"
      :href="link.href"
      :target="link.target"
      class="ivu-card ivu-card-bordered my-2"
    >
      <div class="ivu-card-body">
        <p class="fs-4 fw-bold text-dark">
          {{ link.name }}
        </p>
      </div>
    </component>
  </div>
  <div class="col-12">
    <VButton
      icon="md-add"
      long
      @click="openEditModal"
    >
      Add Link
    </VButton>
  </div>
</template>

<script>
import { linksStore } from '../scripts/links_store'
import { basePath } from 'utils/scripts/configs'
import LinksEdit from './links_edit'

export default {
  name: 'LinksSection',
  computed: {
    linksToRender () {
      return this.defaultLinks.concat(this.customLinks)
    },
    defaultLinks () {
      return [
        {
          is: 'RouterLink',
          name: 'Reports',
          to: { name: 'reports' }
        },
        {
          is: 'RouterLink',
          name: 'Forms',
          to: { name: 'forms' }
        }
      ]
    },
    customLinks () {
      return linksStore.map((link) => {
        const params = { name: link.name }

        const path = link.path.replace(location.origin, '').replace(new RegExp(`^${basePath}`), '/')

        if (path.match(/^https?:/)) {
          params.target = '_blank'
          params.is = 'a'
          params.href = path
        } else {
          const resolvedRoute = this.$router.resolve({ path }, this.$route)

          if (resolvedRoute?.name) {
            params.is = 'RouterLink'
            params.to = resolvedRoute
          } else {
            params.is = 'a'
            params.href = path
          }
        }

        return params
      })
    }
  },
  methods: {
    openEditModal () {
      this.$Drawer.open(LinksEdit, {
      }, {
        title: 'Links',
        closable: true
      })
    }
  }
}
</script>

<style lang="scss">
</style>
