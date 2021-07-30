<template>
  <VButton
    v-if="createAction"
    type="primary"
    icon="md-add"
    data-role="new"
    @click="openForm"
  />
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
  name: 'NewResourceButton',
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
    customActionProps () {
      return {
        data: this.resource,
        formId: this.createAction.preferences.form_id,
        withFooterSubmit: true,
        onSuccess: (result) => {
          this.$Message.info(`${this.resourceTitle} ${this.i18n.has_been_created}`)
          this.$emit('success', result)
        }
      }
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
    openForm () {
      const component = this.createAction.action_type === 'default' ? ResourceForm : CustomFormWrapper
      const props = this.createAction.action_type === 'default' ? this.defaultProps : this.customActionProps

      this.$Drawer.open(component, props, {
        slots: {
          header: () => h(FormHeader, { resource: this.resource, resourceName: this.model.name, action: 'create' })
        },
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    }
  }
}
</script>
