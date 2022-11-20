<template>
  <div
    v-for="link in linksToRender"
    :key="link.name"
    class="col-12 col-md-6 col-lg-4 col-xl-3"
  >
    <component
      :is="link.is"
      v-if="link.to || link.href"
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
      v-if="$can('manage', 'all')"
      icon="md-add"
      long
      @click="openEditModal"
    >
      {{ i18n['add_link'] }}
    </VButton>
  </div>
</template>

<script>
import { linksStore } from '../scripts/links_store'
import { basePath } from 'utils/scripts/configs'
import { canVisit } from '../scripts/can_visit'
import { widthLessThan } from 'utils/scripts/dimensions'
import LinksEdit from './links_edit'

export default {
  name: 'LinksSection',
  computed: {
    linksToRender () {
      return this.defaultLinks.concat(this.customLinks)
    },
    canReadReports () {
      return this.$can('read', 'Motor::Query') || this.$can('read', 'Motor::Dashboard') || this.$can('read', 'Motor::Alert')
    },
    defaultLinks () {
      return [
        widthLessThan('sm') && (this.reportsLink || this.formsLink) && {
          is: 'RouterLink',
          name: 'Data',
          to: { name: 'data_home' }
        },
        this.canReadReports && this.reportsLink && {
          is: 'RouterLink',
          name: 'Reports',
          to: { name: 'reports' }
        },
        this.$can('read', 'Motor::Form') && this.formsLink && {
          is: 'RouterLink',
          name: 'Forms',
          to: { name: 'forms' }
        }
      ].filter(Boolean)
    },
    reportsLink () {
      return linksStore.find((l) => l.link_type === 'reports')
    },
    formsLink () {
      return linksStore.find((l) => l.link_type === 'forms')
    },
    customLinks () {
      return linksStore.map((link) => {
        if (['reports', 'forms'].includes(link.link_type)) {
          return null
        }

        const params = { name: link.name }

        const path = link.path.replace(location.origin, '').replace(new RegExp(`^${basePath}`), '/')

        if (path.match(/^https?:/)) {
          params.target = '_blank'
          params.is = 'a'
          params.href = path
        } else {
          const resolvedRoute = this.$router.resolve({ path }, this.$route)

          if (resolvedRoute?.name) {
            if (canVisit(resolvedRoute)) {
              params.is = 'RouterLink'
              params.to = resolvedRoute
            } else {
              return null
            }
          } else {
            params.is = 'a'
            params.href = path
          }
        }

        return params
      }).filter(Boolean)
    }
  },
  methods: {
    openEditModal () {
      this.$Drawer.open(LinksEdit, {
      }, {
        title: this.i18n.links,
        closable: true
      })
    }
  }
}
</script>

<style lang="scss">
</style>
