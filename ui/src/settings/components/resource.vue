<template>
  <div class="resource-settings">
    <div class="d-flex align-items-center justify-content-between">
      <p class="fs-4 fw-bold mb-2">
        Columns
      </p>
    </div>
    <VueDraggableNext
      :list="resource.columns"
      @change="onColumnMove"
    >
      <ResourceColumn
        v-for="column in resource.columns"
        :key="column.name"
        :resource-name="resource.name"
        :column="column"
        class="mb-2"
      />
    </VueDraggableNext>
    <Card
      v-if="newColumn"
      class="mb-2"
    >
      <ResourceColumnForm
        :column="newColumn"
        @cancel="newColumn = null"
        @submit="onColumnSubmit"
      />
    </Card>
    <div
      v-else
      class="pt-2 border-top"
    >
      <VButton
        long
        icon="md-add"
        class="mb-2"
        @click="addColumn"
      >
        Add Column
      </VButton>
    </div>
    <template v-if="resource.associations.length">
      <p class="fs-4 fw-bold mb-2 mt-3">
        Associations
      </p>
      <VueDraggableNext
        :list="resource.associations"
        @change="onAssociationMove"
      >
        <Association
          v-for="association in resource.associations"
          :key="association.slug"
          :resource-name="resource.name"
          :association="association"
          class="mb-2"
        />
      </VueDraggableNext>
    </template>
  </div>
  <div class="drawer-footer">
    <VButton
      long
      size="large"
      icon="ios-arrow-back"
      @click="$emit('back')"
    >
      All Resources
    </VButton>
  </div>
</template>

<script>
import Association from './resource_association'
import ResourceColumn from './resource_column'
import ResourceColumnForm from './resource_column_form'
import { VueDraggableNext } from 'vue-draggable-next'
import api from 'api'

const defaultColumnAttributes = {
  display_name: '',
  name: '',
  column_type: 'string',
  access_type: 'read_write',
  validators: []
}

export default {
  name: 'ResourceSettings',
  components: {
    Association,
    ResourceColumn,
    ResourceColumnForm,
    VueDraggableNext
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  emits: ['back'],
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
      this.resource.columns.push(column)
      this.newColumn = null

      return api.post('api/resource_configs', {
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
        console.log(error)
      })
    },
    onColumnMove () {
      return api.post('api/configs', {
        data: {
          key: `resources.${this.resource.name}.columns.order`,
          value: this.resource.columns.map((column) => column.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    onAssociationMove () {
      return api.post('api/configs', {
        data: {
          key: `resources.${this.resource.name}.associations.order`,
          value: this.resource.associations.map((assoc) => assoc.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.resource-settings {
  min-height: calc(100% - 73px);
}
</style>
