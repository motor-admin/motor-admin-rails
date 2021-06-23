<template>
  <div
    class="bg-white p-2"
    style="height: calc(100% - 46px)"
  >
    <div>
      <QueriesList
        v-if="isQueriesListOpened"
        :exclude-ids="layout.map((item) => item.query_id)"
        @select="onSelectQuery"
      />
      <VueDraggableNext
        v-else
        :list="layout"
        handle=".handle"
        @end="onEnd"
      >
        <div
          v-for="item in layout"
          :key="item.query_id"
          class="ivu-card ivu-card-bordered cursor-default mb-2"
          @click="$emit('click-item', item)"
        >
          <div class="ivu-card-body d-flex align-items-center justify-content-between py-2">
            <div class="d-flex align-items-center">
              <div class="d-flex flex-column me-2">
                <Icon
                  type="ios-menu"
                  class="cursor-grab handle"
                />
              </div>
              <Contenteditable
                v-model="item.title"
                :with-edit-button="false"
                class="fs-4 fw-bold"
              />
            </div>
            <div class="d-flex align-items-center">
              <SizeControl
                v-model="item.size"
                class="me-1"
              />
              <VButton
                size="small"
                type="text"
                icon="md-trash"
                @click="removeItem(item)"
              />
            </div>
          </div>
        </div>
      </VueDraggableNext>
    </div>
    <div
      class="sticky-footer"
      :class="!layout.length && !isQueriesListOpened ? 'p-0 border-0' : ''"
    >
      <VButton
        long
        type="default"
        :icon="isQueriesListOpened ? 'md-close' : 'md-add'"
        @click="toggleQueriesList"
      >
        {{ isQueriesListOpened ? i18n['cancel'] : i18n['add_query'] }}
      </VButton>
    </div>
  </div>
</template>

<script>
import QueriesList from 'queries/components/list'
import SizeControl from './size_control'
import { queriesStore } from 'reports/scripts/store'

export default {
  name: 'DashboardEditor',
  components: {
    QueriesList,
    SizeControl
  },
  props: {
    dashboard: {
      type: Object,
      required: true
    }
  },
  emits: ['add-query', 'remove-query', 'click-item', 'move'],
  data () {
    return {
      isQueriesListOpened: false
    }
  },
  computed: {
    layout () {
      return this.dashboard.preferences.layout
    },
    sizeOptions () {
      return [
        { label: '25%', value: 25 },
        { label: '33%', value: 33 },
        { label: '50%', value: 50 },
        { label: '66%', value: 66 },
        { label: '100%', value: 100 }
      ]
    }
  },
  mounted () {
    this.isQueriesListOpened = !this.layout.length
  },
  methods: {
    findQueryName (queryId) {
      return (
        this.dashboard.queries.find((query) => query.id === queryId) ||
        queriesStore.find((query) => query.id === queryId)
      )?.name
    },
    onEnd ({ newIndex }) {
      this.$emit('move', this.layout[newIndex])
    },
    removeItem (item) {
      const index = this.layout.indexOf(item)

      this.layout.splice(index, 1)

      this.$emit('remove-query', item.query_id)
    },
    onSelectQuery (query) {
      this.isQueriesListOpened = false

      this.layout.push({ title: query.name, query_id: query.id, size: '3x2' })

      this.$emit('add-query', query.id)
    },
    toggleQueriesList () {
      this.isQueriesListOpened = !this.isQueriesListOpened
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.ion-md-arrow-dropup, .ion-md-arrow-dropdown {
  cursor: pointer;
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
