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
    },
    activeTab: {
      type: String,
      required: false,
      default: ''
    }
  },
  emits: ['back'],
  data () {
    return {
      selectedTab: this.activeTab || 'columns'
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.resource-settings {
  min-height: calc(100% - 62px);
}

.ivu-tabs {
  margin-bottom: 15px;
  position: sticky;
  top: 0;
  z-index: 1;
  padding-top: 2px;
  background: white;
}

:deep(.ivu-tabs-bar) {
  margin: 0
}

:deep(.contenteditable-edit-button) {
  display: none
}

@media screen and (min-width: $breakpoint-md) {
  :deep(.ivu-card:hover) {
    .contenteditable-edit-button {
      display: block
    }
  }
}
</style>
