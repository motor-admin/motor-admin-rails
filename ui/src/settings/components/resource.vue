<template>
  <div class="resource-settings">
    <Tabs
      v-model="selectedTab"
      :position="'center'"
      :tabs="[
        { label: i18n['columns'], value: 'columns' },
        { label: i18n['actions'], value: 'actions' },
        { label: i18n['tabs'], value: 'tabs' },
        { label: i18n['scopes'], value: 'scopes' },
        { label: i18n['associations'], value: 'associations' }
      ]"
    />
    <template
      v-if="selectedTab === 'columns'"
    >
      <Collapse
        v-model="collapseValue"
        simple
        class="mb-3"
        style="margin: 0 -16px"
      >
        <Panel name="1">
          {{ i18n.query_editor }}
          <template #content>
            <ResourceQueryForm
              v-if="collapseValue.includes('1')"
              :resource="resource"
              @close="collapseValue = []"
            />
          </template>
        </Panel>
      </Collapse>

      <Collapse
        v-model="collapseValue"
        simple
        class="mb-3"
        style="margin: 0 -16px"
      >
        <Panel name="2">
          {{ i18n.display_settings }}
          <template #content>
            <ResourceGeneralForm :resource="resource" />
          </template>
        </Panel>
      </Collapse>
      <ResourceColumnsList
        :resource="resource"
      />
    </template>
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
  <div class="sticky-footer">
    <VButton
      long
      size="large"
      icon="ios-arrow-back"
      @click="$emit('back')"
    >
      {{ i18n['all_resources'] }}
    </VButton>
  </div>
</template>

<script>
import ResourceColumnsList from './columns_list'
import AssociationsList from './associations_list'
import ActionsList from './actions_list'
import TabsList from './tabs_list'
import ScopesList from './scopes_list'
import ResourceQueryForm from './resource_query_form'
import ResourceGeneralForm from './resource_general'
import Tabs from 'utils/components/tabs'

export default {
  name: 'ResourceSettings',
  components: {
    AssociationsList,
    ResourceColumnsList,
    ActionsList,
    ScopesList,
    TabsList,
    Tabs,
    ResourceGeneralForm,
    ResourceQueryForm
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
      collapseValue: [],
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
  margin-left: -16px;
  margin-right: -16px;
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

    img {
      border-radius: 5px;
      background: rgba(1,1,1,0.05);
    }
  }
}
</style>
