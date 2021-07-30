<template>
  <template v-if="withButtons">
    <VButton
      v-for="(action, index) in buttonActions"
      :key="action.name"
      :class="index !== (buttonActions.length - 1) || dropdownActions.length ? 'me-2' : ''"
      :type="buttonTypes[action.name]"
      :ghost="!!buttonTypes[action.name]"
      @click="applyAction(action)"
    >
      {{ action.display_name }}
    </VButton>
  </template>
  <Dropdown
    v-if="(withDeselect || hasActions) && dropdownActions.length"
    trigger="click"
    :placement="placement"
  >
    <VButton
      :ghost="buttonGhost"
      :type="buttonType"
      :class="{ 'bg-white': buttonGhost }"
    >
      {{ dropdownLabel }}
      <Icon type="ios-arrow-down" />
    </VButton>
    <template #list>
      <DropdownMenu>
        <template
          v-for="action in customActions"
          :key="action.name"
        >
          <DropdownItem
            v-if="dropdownActions.indexOf(action) !== -1"
            :disabled="resources.length > 1 && action.action_type === 'form'"
            @click="applyAction(action)"
          >
            {{ action.display_name }}
          </DropdownItem>
        </template>
        <DropdownItem
          v-if="editAction && canEdit && dropdownActions.indexOf(editAction) !== -1"
          :disabled="resources.length > 1"
          @click="applyAction(editAction)"
        >
          {{ i18n['edit'] }}
        </DropdownItem>
        <DropdownItem
          v-if="removeAction && canRemove && dropdownActions.indexOf(removeAction) !== -1"
          :divided="!!editAction"
          class="text-danger"
          @click="applyAction(removeAction)"
        >
          {{ i18n['remove'] }}
        </DropdownItem>
        <DropdownItem
          v-if="withDeselect"
          :divided="hasActions"
          @click="deselect"
        >
          {{ i18n['deselect_all'] }}
        </DropdownItem>
      </DropdownMenu>
    </template>
  </Dropdown>
</template>

<script>
import api from 'api'
import axios from 'axios'
import { h } from 'vue'
import { modelNameMap } from '../scripts/schema'
import ResourceForm from './form'
import FormHeader from './form_header'
import { interpolate, truncate } from 'utils/scripts/string'
import CustomFormWrapper from 'custom_forms/components/form_wrapper'
import singularize from 'inflected/src/singularize'
import { loadCredentials } from 'utils/scripts/auth_credentials'
import { i18nDict } from 'utils/scripts/configs'

const MAX_BUTTONS_LENGTH = 50

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
    withButtons: {
      type: Boolean,
      required: false,
      default: false
    },
    placement: {
      type: String,
      required: false,
      default: 'bottom'
    },
    resourceName: {
      type: String,
      required: true
    },
    label: {
      type: String,
      required: false,
      default: i18nDict.actions
    }
  },
  emits: ['start-action', 'finish-action'],
  computed: {
    dropdownLabel () {
      if (this.i18n.actions !== this.label) {
        return this.label
      } else {
        return this.buttonActions.length ? this.i18n.more : this.i18n.actions
      }
    },
    buttonTypes () {
      return {
        edit: 'primary',
        remove: 'error'
      }
    },
    partitionedActions () {
      return this.permittedActions.reduce(([buttonActions, dropdownActions, len], action) => {
        if (len < MAX_BUTTONS_LENGTH) {
          len += action.display_name.length + 6
          buttonActions.push(action)
        } else {
          dropdownActions.push(action)
        }

        return [buttonActions, dropdownActions, len]
      }, [[], [], 0]).slice(0, 2)
    },
    buttonActions () {
      if (!this.withButtons) {
        return []
      }

      if (this.partitionedActions[1].length > 1) {
        return this.partitionedActions[0]
      } else {
        return this.permittedActions
      }
    },
    dropdownActions () {
      if (!this.withButtons) {
        return this.permittedActions
      }

      if (this.partitionedActions[1].length > 1) {
        return this.partitionedActions[1]
      } else {
        return []
      }
    },
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
    canEdit () {
      return this.model.primary_key && this.resources.some((res) => this.$can('edit', this.model.class_name, res))
    },
    canRemove () {
      return this.model.primary_key && this.resources.some((res) => this.$can('destroy', this.model.class_name, res))
    },
    hasActions () {
      return this.canEdit || this.canRemove || this.customActions.length > 0
    },
    customActions () {
      return this.permittedActions.filter((action) => {
        return !['create', 'edit', 'remove'].includes(action.name)
      })
    },
    permittedActions () {
      return this.model.actions.filter((action) => {
        return action.name !== 'create' && action.visible && this.resources.some((res) => {
          return this.$can(action.name, this.model.class_name, res)
        })
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
        this.$Message.info(this.i18n.action_has_been_applied)
      }).catch((error) => {
        if (error.response.data?.errors) {
          this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
        } else {
          this.$Message.error(`${this.i18n.action_has_failed_with_code} ${error.response.status}`)
        }
      }).finally(() => {
        this.$emit('finish-action', action.name)
      })
    },
    methodRequest (resource, action) {
      return api.put(`data/${this.model.slug}/${resource[this.model.primary_key]}/${action.preferences.method_name}`)
    },
    apiRequest (resource, action) {
      const path = interpolate(action.preferences.api_path, resource)

      return loadCredentials().then((credentials) => {
        return axios.post(path, {}, { headers: credentials.headers })
      })
    },
    openForm (resource, action) {
      const data = action.name === 'edit'
        ? resource
        : {
            id: resource[this.model.primary_key],
            [`${this.model.name}_${this.model.primary_key}`]: resource[this.model.primary_key]
          }

      this.$Drawer.open(CustomFormWrapper, {
        data,
        withFooterSubmit: true,
        formId: action.preferences.form_id,
        onSuccess: (result) => {
          this.$emit('finish-action', action.name)
        },
        onError: (result) => {
        }
      }, {
        slots: {
          header: () => h(FormHeader, { resource: this.resource, resourceName: this.resourceName, action: action.name })
        },
        closable: true
      })
    },
    edit () {
      if (this.resources.length !== 1) {
        return
      }

      const resourceTitle = `${singularize(this.model.display_name)} #${this.resource.id}`

      this.$Drawer.open(ResourceForm, {
        resource: this.resource,
        action: 'edit',
        resourceName: this.resourceName,
        onClose: () => {
          this.$Drawer.remove()
        },
        onSuccess: (data) => {
          this.$Drawer.remove()
          this.$Message.info(`${resourceTitle} ${this.i18n.has_been_updated}`)
          this.$emit('finish-action', 'edit')
        }
      }, {
        slots: {
          header: () => h(FormHeader, { resource: this.resource, resourceName: this.resourceName, action: 'edit' })
        },
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    },
    remove () {
      this.$Dialog.confirm({
        title: (
          this.resources.length > 1
            ? [this.i18n.items_will_be_removed.replace('%{count}', this.resources.length), this.i18n.are_you_sure].join('. ')
            : [this.i18n.selected_item_will_be_removed, this.i18n.are_you_sure].join('. ')
        ),
        closable: true,
        onOk: () => {
          this.$emit('start-action', 'remove')

          Promise.all(this.resources.map(this.removeRequest)).then((result) => {
            if (this.resources.length > 1) {
              this.$Message.info(`${this.resources.length} ${this.i18n.items_have_been_removed}`)
            } else {
              this.$Message.info(this.i18n.selected_item_has_been_removed)
            }
          }).catch((error) => {
            console.error(error)

            if (error.response.data?.errors) {
              this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
            } else {
              this.$Message.error(this.i18n.unable_to_remove_items)
            }
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
