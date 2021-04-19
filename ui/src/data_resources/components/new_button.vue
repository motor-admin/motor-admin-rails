<template>
  <VButton
    type="primary"
    icon="md-add"
    @click="openForm"
  />
</template>

<script>
import { modelNameMap } from '../scripts/schema'

import ResourceForm from './form'

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
    defaultValues () {
      return this.model.columns.reduce((acc, column) => {
        if (column.default_value) {
          acc[column.name] = column.default_value
        }

        return acc
      }, {})
    },
    resource () {
      const resource = JSON.parse(JSON.stringify(this.defaultValues))

      if (this.parentResource) {
        resource[`${this.parentResource.name}_id`] = this.parentResource.id
      }

      return resource
    }
  },
  methods: {
    openForm () {
      const resourceTitle = titleize(this.resourceName)

      this.$Drawer.open(ResourceForm, {
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

          this.$Message.info(`${resourceTitle} has been created`)
          this.$emit('success', data)
        }
      }, {
        title: `Create ${resourceTitle}`,
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    }
  }
}
</script>
