<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
      :style="{ opacity: association.visible ? 1 : 0.5 }"
    >
      <div class="ivu-card-body d-flex align-items-center justify-content-between">
        <div class="d-flex align-items-center">
          <Icon
            type="ios-menu"
            class="me-3 cursor-grab handle"
          />
          <Checkbox
            v-model="association.visible"
            class="m-0"
            @change="persistChanges"
          />
          <CustomIcon
            :type="association.icon"
            :size="26"
            class="p-1 mx-1 cursor-pointer"
            @click.stop="openIconEditor"
          />
          <Contenteditable
            v-model="association.display_name"
            class="fs-5 fw-bold"
            @click.stop
            @change="persistChanges"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import CustomIcon from 'utils/components/custom_icon'
import IconSelect from './icon_select'

export default {
  name: 'AssociationItem',
  components: {
    CustomIcon
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    association: {
      type: Object,
      required: true
    }
  },
  methods: {
    openIconEditor () {
      this.$Modal.open(IconSelect, {
        onSelect: (icon) => {
          this.association.icon = icon

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
          name: this.resourceName,
          preferences: {
            associations: [
              this.association
            ]
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
  padding: 5px 16px 6px 16px;
}
</style>
