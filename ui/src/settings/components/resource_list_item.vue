<template>
  <div
    class="ivu-card ivu-card-bordered"
    :style="{ opacity: resource.visible ? 1 : 0.5 }"
  >
    <div class="ivu-card-body d-flex align-items-center justify-content-between">
      <div class="d-flex align-items-center">
        <Icon
          type="ios-menu"
          class="me-3 cursor-grab handle"
        />
        <Checkbox
          v-model="resource.visible"
          class="m-0"
          @click.stop
          @change="persistChanges"
        />
        <CustomIcon
          :type="resource.icon"
          :size="36"
          class="p-2 mx-1"
          @click.stop="openIconEditor"
        />
        <Contenteditable
          v-model="resource.display_name"
          class="fs-4 fw-bold"
          @click.stop
          @change="persistChanges"
        />
      </div>
      <div class="d-flex align-items-center">
        <Icon type="ios-arrow-forward" />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import CustomIcon from 'utils/components/custom_icon'
import IconSelect from './icon_select'

export default {
  name: 'ResourceSettingsItem',
  components: {
    CustomIcon
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  methods: {
    openIconEditor () {
      this.$Modal.open(IconSelect, {
        onSelect: (icon) => {
          this.resource.icon = icon

          this.persistChanges()

          this.$Modal.remove()
        },
        onClose: () => {
          this.$Modal.remove()
        }
      })
    },
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            display_name: this.resource.display_name,
            icon: this.resource.icon,
            visible: this.resource.visible
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-card-body {
  padding: 10px 16px;
}
</style>
