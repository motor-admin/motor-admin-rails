<template>
  <VueDraggableNext
    :list="resource.columns"
    handle=".handle"
    @change="onColumnMove"
  >
    <ResourceColumn
      v-for="column in resource.columns"
      :key="column.name"
      :resource-name="resource.name"
      :column="column"
      class="pb-2"
      @reorder="onColumnMove"
    />
  </VueDraggableNext>
  <Card
    v-if="newColumn"
  >
    <ResourceColumnForm
      ref="newForm"
      :column="newColumn"
      :resource-name="resource.name"
      @cancel="newColumn = null"
      @submit="onColumnSubmit"
    />
  </Card>
  <div
    v-else
    class="py-2 border-top"
  >
    <VButton
      long
      icon="md-add"
      @click="addColumn"
    >
      {{ i18n['add_column'] }}
    </VButton>
  </div>
</template>

<script>
import ResourceColumn from './resource_column'
import ResourceColumnForm from './resource_column_form'
import api from 'api'
import { underscore } from 'utils/scripts/string'

const defaultColumnAttributes = {
  display_name: '',
  name: '',
  column_type: 'string',
  access_type: 'read_write',
  format: {},
  validators: []
}

export default {
  name: 'ResourceColumnsList',
  components: {
    ResourceColumn,
    ResourceColumnForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      newColumn: null
    }
  },
  methods: {
    addColumn () {
      this.newColumn = { ...defaultColumnAttributes, virtual: true }

      this.$nextTick(() => {
        this.$refs.newForm.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
      })
    },
    onColumnSubmit (column) {
      if (column.column_type === 'association') {
        column.name = column.format.association_name
      } else {
        column.name = underscore(column.display_name)
      }

      if (column.reference?.model_name === 'active_storage/attachment') {
        column.name += '_attachment'
      }

      this.newColumn = null

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            columns: [
              column
            ]
          }
        }
      }).then((result) => {
        this.resource.columns.push(column)
      }).catch((error) => {
        console.error(error)
      })
    },
    onColumnMove () {
      return api.post('configs', {
        data: {
          key: `resources.${this.resource.name}.columns.order`,
          value: this.resource.columns.map((column) => column.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
