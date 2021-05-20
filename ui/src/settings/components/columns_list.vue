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
      :column="newColumn"
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
      Add Column
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
    },
    onColumnSubmit (column) {
      column.name = underscore(column.display_name)

      this.resource.columns.push(column)
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
