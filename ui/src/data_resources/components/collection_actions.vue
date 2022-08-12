<template>
  <VButton
    v-if="createAction && !customActions.length"
    type="primary"
    icon="md-add"
    data-role="new"
    @click="openForm(createAction)"
  />
  <Dropdown
    v-else-if="customActions.length"
    trigger="click"
    placement="bottom-end"
  >
    <VButton
      type="primary"
      icon="ios-arrow-down"
    />
    <template #list>
      <DropdownMenu>
        <DropdownItem
          v-if="createAction"
          @click="openForm(createAction)"
        >
          {{ i18n['create'] }}
        </DropdownItem>
        <template
          v-for="action in customActions"
          :key="action.name"
        >
          <DropdownItem
            @click="openForm(action)"
          >
            {{ action.display_name }}
          </DropdownItem>
        </template>
      </DropdownMenu>
    </template>
  </Dropdown>
</template>

<script>
import { h } from 'vue'

import { modelNameMap } from '../scripts/schema'
import { buildDefaultValues } from '../scripts/form_utils'

import ResourceForm from './form'
import FormHeader from './form_header'
import CustomFormWrapper from 'custom_forms/components/form_wrapper'

import singularize from 'inflected/src/singularize'

export default {
  name: 'ResourceCollectionActions',
  props: {
    model: {
      type: Object,
      required: true
    },
    association: {
      type: Object,
      required: false,
      default: null
    },
    parentResource: {
      type: Object,
      required: false,
      default: null
    }
  },
  emits: ['success'],
  computed: {
    resourceTitle () {
      return singularize(this.model.display_name)
    },
    createAction () {
      return this.model.actions.find((action) => {
        return action.name === 'create' && action.visible
      })
    },
    customActions () {
      return this.model.actions.filter((action) => {
        return action.apply_on === 'collection' && action.visible && action.action_type === 'form' && action.name !== 'create'
      })
    },
    parentModel () {
      return modelNameMap[this.parentResource.name]
    },
    resource () {
      const resource = buildDefaultValues(this.model)

      if (this.association?.polymorphic) {
        resource[this.association.foreign_key] = parseInt(this.parentResource.id)
        resource[this.association.foreign_key.replace('_id', '_type')] = this.parentModel.class_name

        if (this.association.model_name === 'active_storage/attachment') {
          resource.name = this.association.name.replace(/_attachments?$/, '')
        }
      } else if (this.parentResource) {
        resource[this.association.foreign_key] = this.parentResource[this.association.primary_key]
      }

      return resource
    },
    defaultProps () {
      return {
        action: 'new',
        resource: this.resource,
        resourceName: this.model.name,
        parentResourceName: this.parentResource?.name,
        parentResourceId: this.parentResource?.id,
        associationName: this.association?.name,
        onClose: () => {
          this.$Drawer.remove()
        },
        onSuccess: (result) => {
          this.$Message.info(`${this.resourceTitle} ${this.i18n.has_been_created}`)
          this.$emit('success', result)
        }
      }
    }
  },
  methods: {
    customActionProps (action) {
      return {
        data: this.parentResource ? { [`${this.parentModel.name}_${this.parentModel.primary_key}`]: this.parentResource.id } : {},
        formId: action.preferences.form_id,
        withFooterSubmit: true,
        onSuccess: (result) => {
          this.$Message.info(`${this.resourceTitle} ${this.i18n.has_been_created}`)
          this.$emit('success', result)
        }
      }
    },
    openForm (action) {
      const component = action.action_type === 'default' ? ResourceForm : CustomFormWrapper
      const props = action.action_type === 'default' ? this.defaultProps : this.customActionProps(action)

      this.$Drawer.open(component, props, {
        slots: {
          header: () => h(FormHeader, { resource: this.resource, resourceName: this.model.name, action: 'create' })
        },
        handleClickOutside () {
          if (this.$el.querySelector('form[data-form-edited="true"]')) {
            this.$Dialog.confirm({
              title: this.i18n.there_are_unsaved_changes_close_form,
              closable: true,
              onOk: () => {
                this.close()
              }
            })
          } else {
            this.close()
          }
        },
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    }
  }
}
</script>

<style lang="scss">
</style>
