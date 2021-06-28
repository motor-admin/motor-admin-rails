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
    defaultValues () {
      return this.model.columns.reduce((acc, column) => {
        if (column.default_value !== null) {
          acc[column.name] = column.default_value
        }

        return acc
      }, {})
    },
    createAction () {
      return this.model.actions.find((action) => {
        return action.name === 'create' && action.visible
      })
    },
    resource () {
      const resource = JSON.parse(JSON.stringify(this.defaultValues))

      if (this.association?.polymorphic) {
        resource[this.association.foreign_key] = parseInt(this.parentResource.id)
        resource[this.association.foreign_key.replace('_id', '_type')] = modelNameMap[this.parentResource.name].class_name

        if (this.association.model_name === 'active_storage/attachment') {
          resource.name = this.association.name.replace(/_attachments?$/, '')
        }
      } else if (this.parentResource) {
        resource[`${this.parentResource.name}_id`] = parseInt(this.parentResource.id)
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
        onClose: () => {
          this.$Drawer.remove()
        },
        onSuccess: (data) => {
          if (data.button === 'save') {
            this.$Drawer.remove()
          }

          this.$Message.info(`${this.resourceTitle} ${this.i18n.has_been_created}`)
          this.$emit('success', data)
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
