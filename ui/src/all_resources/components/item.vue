<template>
  <RouterLink
    class="item ivu-card ivu-card-bordered mb-2"
    :to="toParams"
  >
    <div class="ivu-card-body">
      <p class="fs-4 fw-bold text-dark">
        <Icon :type="iconClass" />
        {{ item.display_name || item.name || item.title }}
        <VButton
          v-if="itemType === 'table'"
          class="text-dark float-right pb-2"
          type="text"
          icon="md-settings"
          @click.prevent="openResourceSettings"
        />
        <VButton
          v-else
          class="text-dark float-right pb-2"
          type="text"
          icon="md-trash"
          @click.prevent="remove"
        />
      </p>
      <div />
    </div>
  </RouterLink>
</template>

<script>
import api from 'api'
import { titleize } from 'utils/scripts/string'
import ResourcesSettings from 'settings/components/resources_list'

export default {
  name: 'ReportItem',
  props: {
    item: {
      type: Object,
      required: true
    },
    itemType: {
      type: String,
      required: true
    }
  },
  emits: ['remove'],
  computed: {
    toParams () {
      if (this.itemType === 'table') {
        return { name: 'resources', params: { fragments: [this.item.slug] } }
      } else {
        return { name: this.itemType, params: { id: this.item.id } }
      }
    },
    iconClass () {
      return {
        query: 'md-list',
        dashboard: 'md-analytics',
        alert: 'md-notifications',
        table: 'md-grid'
      }[this.itemType]
    },
    apiPath () {
      if (this.itemType === 'query') {
        return `queries/${this.item.id}`
      } else if (this.itemType === 'dashboard') {
        return `dashboards/${this.item.id}`
      } else if (this.itemType === 'alert') {
        return `alerts/${this.item.id}`
      } else {
        return ''
      }
    }
  },
  methods: {
    openResourceSettings () {
      this.$Drawer.open(ResourcesSettings, {
        selectedResource: this.item,
        onChangeResource: this.onChangeResource
      }, {
        title: this.settingsDrawerTitle(this.item),
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    },
    onChangeResource (resource) {
      this.$Drawer.component.setTitle(this.settingsDrawerTitle(resource))
    },
    settingsDrawerTitle (resource) {
      if (resource) {
        return `${resource.display_name} Settings`
      } else {
        return 'Settings'
      }
    },
    remove () {
      this.$Dialog.confirm({
        title: 'Selected item will be removed. Are you sure?',
        closable: true,
        onOk: () => {
          api.delete(this.apiPath).then((result) => {
            this.$Message.info(`${titleize(this.itemType)} has been removed succesfully`)

            this.$emit('remove')
          }).catch((error) => {
            console.error(error)
            this.$Message.error('Unable to remove item')
          })
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.item {
  button {
    display: none
  }
}

.item:hover {
  button {
    display: block
  }
}
</style>
