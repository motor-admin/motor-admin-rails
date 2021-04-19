<template>
  <ResourceSettings
    v-if="dataSelectedResource"
    :resource="dataSelectedResource"
    @back="dataSelectedResource = null"
  />
  <VueDraggableNext
    v-else
    :list="schema"
    ghost-class="ghost"
    @change="updateOrder"
  >
    <ResourceItem
      v-for="model in schema"
      :key="model.slug"
      :resource="model"
      class="cursor-pointer mb-2"
      @click="dataSelectedResource = model"
    />
  </VueDraggableNext>
</template>

<script>
import ResourceItem from './resource_list_item'
import ResourceSettings from './resource'
import { VueDraggableNext } from 'vue-draggable-next'
import { schema } from 'data_resources/scripts/schema'
import api from 'api'

export default {
  name: 'ResourcesSettings',
  components: {
    ResourceSettings,
    ResourceItem,
    VueDraggableNext
  },
  props: {
    selectedResource: {
      type: Object,
      required: false,
      default: null
    }
  },
  emits: ['change-resource'],
  data () {
    return {
      dataSelectedResource: this.selectedResource
    }
  },
  computed: {
    schema: () => schema
  },
  watch: {
    dataSelectedResource () {
      this.$emit('change-resource', this.dataSelectedResource)
    }
  },
  methods: {
    updateOrder () {
      return api.post('configs', {
        data: {
          key: 'resources.order',
          value: this.schema.map((e) => e.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
