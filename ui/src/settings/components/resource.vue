<template>
  <div class="resource-settings">
    <Tabs
      v-model="selectedTab"
      :position="'center'"
      :tabs="[
        { label: 'Columns', value: 'columns' },
        { label: 'Actions', value: 'actions' },
        { label: 'Tabs', value: 'tabs' },
        { label: 'Scopes', value: 'scopes' },
        { label: 'Associations', value: 'associations' }
      ]"
    />
    <ResourceColumnsList
      v-if="selectedTab === 'columns'"
      :resource="resource"
    />
    <AssociationsList
      v-else-if="selectedTab === 'associations'"
      :resource="resource"
    />
    <ScopesList
      v-else-if="selectedTab === 'scopes'"
      :resource="resource"
    />
    <ActionsList
      v-else-if="selectedTab === 'actions'"
      :resource="resource"
    />
    <TabsList
      v-else-if="selectedTab === 'tabs'"
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
import ScopesList from './scopes_list'
import Tabs from 'utils/components/tabs'

export default {
  name: 'ResourceSettings',
  components: {
    AssociationsList,
    ResourceColumnsList,
    ActionsList,
    ScopesList,
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
