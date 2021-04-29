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
          v-for="action in customActions"
          :key="action.name"
          :disabled="resources.length > 1 && action.action_type === 'form'"
          @click="applyAction(action)"
        >
          {{ action.display_name }}
        </DropdownItem>
        <DropdownItem
          v-if="editAction"
          :disabled="resources.length > 1"
          @click="applyAction(editAction)"
        >
          Edit
        </DropdownItem>
        <DropdownItem
          v-if="removeAction"
          :divided="editAction"
          class="text-danger"
          @click="applyAction(removeAction)"
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
import axios from 'axios'
import { modelNameMap } from '../scripts/schema'
import ResourceForm from './form'
import { titleize, interpolate } from 'utils/scripts/string'
import CustomFormModal from 'custom_forms/components/form_modal'

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
    editAction () {
      return this.model.actions.find((action) => {
        return action.name === 'edit' && action.visible
      })
    },
    removeAction () {
      return this.model.actions.find((action) => {
        return action.name === 'remove' && action.visible
      })
    },
    customActions () {
      return this.model.actions.filter((action) => {
        return !['create', 'edit', 'remove'].includes(action.name) && action.visible
      })
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
    applyAction (action) {
      if (action.name === 'edit' && action.action_type === 'default') {
        return this.edit()
      }

      if (action.name === 'remove' && action.action_type === 'default') {
        return this.remove()
      }

      if (action.action_type === 'form' && this.resources.length > 1) {
        return
      }

      if (action.action_type === 'form') {
        return this.openForm(this.resource, action)
      }

      this.$emit('start-action', action.name)

      const requests = this.resources.map((resource) => {
        if (action.action_type === 'method') {
          return this.methodRequest(resource, action)
        } else if (action.action_type === 'api') {
          return this.apiRequest(resource, action)
        } else {
          return Promise.resolve({})
        }
      })

      Promise.all(requests).then((result) => {
        this.$Message.info('Action has been applied!')
      }).catch((error) => {
        this.$Message.error(`Action failed with code ${error.response.status}`)
      }).finally(() => {
        this.$emit('finish-action', action.name)
      })
    },
    methodRequest (resource, action) {
      return api.put(`data/${this.model.slug}/${resource[this.model.primary_key]}/${action.preferences.method_name}`)
    },
    apiRequest (resource, action) {
      const path = interpolate(action.preferences.api_path, resource)

      return axios.post(path)
    },
    openForm (resource, action) {
      const data = action.name === 'edit'
        ? resource
        : {
            id: resource[this.model.primary_key],
            [`${this.model.name}_${this.model.primary_key}`]: resource[this.model.primary_key]
          }

      this.$Drawer.open(CustomFormModal, {
        data,
        formId: action.preferences.form_id,
        onSuccess: (result) => {
          this.$emit('finish-action', action.name)
        },
        onError: (result) => {
        }
      }, {
        title: action.display_name,
        closable: true
      })
    },
    edit () {
      if (this.resources.length !== 1) {
        return
      }

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
          this.$Message.info(`${resourceTitle} has been updated`)
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
            console.error(error)
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
