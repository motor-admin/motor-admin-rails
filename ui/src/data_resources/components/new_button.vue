<template>
  <VButton
    v-if="createAction"
    type="primary"
    icon="md-add"
    @click="openForm"
  />
</template>

<script>
import { modelNameMap } from '../scripts/schema'

import ResourceForm from './form'
import CustomFormModal from 'custom_forms/components/form_modal'

import { titleize } from 'utils/scripts/string'

export default {
  name: 'NewResourceButton',
  props: {
    resourceName: {
      type: String,
      required: true
    },
    parentResource: {
      type: Object,
      required: false,
      default: null
    }
  },
  emits: ['success'],
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    },
    resourceTitle () {
      return titleize(this.resourceName)
    },
    defaultValues () {
      return this.model.columns.reduce((acc, column) => {
        if (column.default_value) {
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

      if (this.parentResource) {
        resource[`${this.parentResource.name}_id`] = this.parentResource.id
      }

      return resource
    },
    customActionProps () {
      return {
        data: this.resource,
        formId: this.createAction.preferences.form_id,
        onSuccess: (result) => {
          this.$Message.info(`${this.resourceTitle} has been created`)
          this.$emit('success', result)
        }
      }
    },
    defaultProps () {
      return {
        action: 'new',
        resource: this.resource,
        resourceName: this.resourceName,
        onClose: () => {
          this.$Drawer.remove()
        },
        onSuccess: (data) => {
          if (data.button === 'save') {
            this.$Drawer.remove()
          }

          this.$Message.info(`${this.resourceTitle} has been created`)
          this.$emit('success', data)
        }
      }
    }
  },
  methods: {
    openForm () {
      const component = this.createAction.action_type === 'default' ? ResourceForm : CustomFormModal
      const props = this.createAction.action_type === 'default' ? this.defaultProps : this.customActionProps

      this.$Drawer.open(component, props, {
        title: `Create ${this.resourceTitle}`,
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    }
  }
}
</script>
