<template>
  <div class="resource-settings">
    <Tabs
      v-model="selectedTab"
      :position="'center'"
      :tabs="[
        { label: 'Columns', value: 'columns' },
        { label: 'Actions', value: 'actions' },
        { label: 'Tabs', value: 'tabs' },
        { label: 'Associations', value: 'associations' }
      ]"
    />
    <ResourceColumnsList
      v-if="selectedTab === 'columns'"
      :resource="resource"
    />
    <AssociationsList
      v-if="selectedTab === 'associations'"
      :resource="resource"
    />
    <ActionsList
      v-if="selectedTab === 'actions'"
      :resource="resource"
    />
    <TabsList
      v-if="selectedTab === 'tabs'"
      :resource="resource"
    />
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
import ResourceColumnsList from './columns_list'
import AssociationsList from './associations_list'
import ActionsList from './actions_list'
import TabsList from './tabs_list'
import Tabs from 'utils/components/tabs'

export default {
  name: 'ResourceSettings',
  components: {
    AssociationsList,
    ResourceColumnsList,
    ActionsList,
    TabsList,
    Tabs
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
      selectedTab: 'columns'
    }
  }
}
</script>

<style lang="scss" scoped>
.resource-settings {
  min-height: calc(100% - 62px);
}
</style>
