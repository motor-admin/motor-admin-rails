<template>
  <VueDraggableNext
    :list="resource.tabs"
    handle=".handle"
    @change="onTabMove"
  >
    <TabItem
      v-for="tab in resource.tabs"
      :key="tab.name"
      :resource="resource"
      :tab="tab"
      class="pb-2"
    />
  </VueDraggableNext>
  <Card
    v-if="newTab"
  >
    <TabForm
      :tab="newTab"
      :resource="resource"
      :with-name="true"
      @cancel="newTab = null"
      @submit="onTabSubmit"
    />
  </Card>
  <div
    v-else
    class="py-2 border-top"
  >
    <VButton
      long
      icon="md-add"
      @click="addTab"
    >
      Add Tab
    </VButton>
  </div>
</template>

<script>
import TabItem from './resource_tab'
import TabForm from './resource_tab_form'
import api from 'api'

const defaultTabAttributes = {
  display_name: '',
  name: '',
  tab_type: '',
  preferences: {},
  visible: true
}

export default {
  name: 'TabsList',
  components: {
    TabItem,
    TabForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      newTab: null
    }
  },
  methods: {
    addTab () {
      this.newTab = { ...defaultTabAttributes }
    },
    onTabSubmit (tab) {
      this.resource.tabs.push(tab)
      this.newTab = null

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            tabs: [
              tab
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    onTabMove () {
      return api.post('configs', {
        data: {
          key: `resources.${this.resource.name}.tabs.order`,
          value: this.resource.tabs.map((tab) => tab.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
