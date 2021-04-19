<template>
  <VueDraggableNext
    :list="resource.associations"
    @change="onAssociationMove"
  >
    <Association
      v-for="association in resource.associations"
      :key="association.slug"
      :resource-name="resource.name"
      :association="association"
      class="pb-2"
    />
  </VueDraggableNext>
</template>

<script>
import Association from './resource_association'
import api from 'api'

export default {
  name: 'ResourceAssociationsList',
  components: {
    Association
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  methods: {
    onAssociationMove () {
      return api.post('configs', {
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
