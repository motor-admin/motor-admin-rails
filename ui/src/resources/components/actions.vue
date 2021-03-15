<template>
  <Dropdown
    trigger="click"
    transfer
  >
    <VButton
      :ghost="buttonGhost"
      :type="buttonType"
      :class="{ 'bg-white': buttonGhost }"
    >
      {{ label }}
      <Icon type="ios-arrow-down" />
    </VButton>
    <template #list>
      <DropdownMenu>
        <DropdownItem
          :disabled="resources.length > 1"
          @click="edit"
        >
          Edit
        </DropdownItem>
        <DropdownItem
          divided
          class="text-danger"
          @click="remove"
        >
          Remove
        </DropdownItem>
        <DropdownItem
          v-if="withDeselect"
          divided
          @click="deselect"
        >
          Deselect All
        </DropdownItem>
      </DropdownMenu>
    </template>
  </Dropdown>
</template>

<script>
import api from 'api'
import { modelNameMap } from 'utils/scripts/schema'
import ResourceForm from './form'
import { titleize } from 'utils/scripts/string'

export default {
  name: 'ResourceActions',
  props: {
    resources: {
      type: Array,
      required: true
    },
    buttonType: {
      type: String,
      required: false,
      default: 'primary'
    },
    buttonGhost: {
      type: Boolean,
      required: false,
      default: true
    },
    withDeselect: {
      type: Boolean,
      required: false,
      default: false
    },
    resourceName: {
      type: String,
      required: true
    },
    label: {
      type: String,
      required: false,
      default: 'Actions'
    }
  },
  emits: ['start-action', 'finish-action'],
  computed: {
    resource () {
      return this.resources[0]
    },
    model () {
      return modelNameMap[this.resourceName]
    }
  },
  methods: {
    deselect () {
      this.resources.forEach((resource) => {
        resource._selected = false
      })
    },
    removeRequest (resource) {
      return api.delete(`data/${this.model.slug}/${resource[this.model.primary_key]}`)
    },
    edit () {
      const resourceTitle = `${titleize(this.resourceName)} #${this.resource.id}`

      this.$Drawer.open(ResourceForm, {
        resource: this.resource,
        action: 'edit',
        resourceName: this.resourceName,
        onClose: () => {
          this.$Drawer.remove()
        },
        onSuccess: (data) => {
          this.$Drawer.remove()
          this.$Message.success(`${resourceTitle} has been updated`)
          this.$emit('finish-action', 'edit')
        }
      }, {
        title: `Edit ${resourceTitle}`,
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    },
    remove () {
      this.$Dialog.confirm({
        title: (
          this.resources.length > 1
            ? `${this.resources.length} items will be removed. Are you sure?`
            : 'Selected item will be removed. Are you sure?'
        ),
        closable: true,
        onOk: () => {
          this.$emit('start-action', 'remove')

          Promise.all(this.resources.map(this.removeRequest)).then((result) => {
            if (this.resources.length > 1) {
              this.$Message.info(`${this.resources.length} items has been removed`)
            } else {
              this.$Message.info('Selected item has been removed')
            }
          }).catch((error) => {
            console.erro(error)
            this.$Message.error('Unable to remove items')
          }).finally(() => {
            this.$emit('finish-action', 'remove')
          })
        }
      })
    }
  }
}
</script>

<style lang="scss">
</style>
