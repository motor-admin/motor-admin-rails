<template>
  <ResourceSettings
    v-if="dataSelectedResource"
    :resource="dataSelectedResource"
    :active-tab="settingsType"
    @back="dataSelectedResource = null"
  />
  <div
    v-else
    class="pt-3"
  >
    <VueDraggableNext
      :list="schema"
      ghost-class="ghost"
      handle=".handle"
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
  </div>
</template>

<script>
import ResourceItem from './resource_list_item'
import ResourceSettings from './resource'
import { schema } from 'data_resources/scripts/schema'
import api from 'api'

export default {
  name: 'ResourcesSettings',
  components: {
    ResourceSettings,
    ResourceItem
  },
  props: {
    selectedResource: {
      type: Object,
      required: false,
      default: null
    },
    settingsType: {
      type: String,
      required: false,
      default: ''
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

<style lang="scss" scoped>
@import 'utils/styles/variables';

:deep(.contenteditable-edit-button) {
  display: none
}

@media screen and (min-width: $breakpoint-md) {
  :deep(.ivu-card:hover) {
    .contenteditable-edit-button {
      display: block
    }

    img {
      border-radius: 5px;
      background: rgba(1,1,1,0.05);
    }
  }
}
</style>
