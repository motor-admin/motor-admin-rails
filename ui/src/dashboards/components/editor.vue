<template>
  <div
    class="bg-white p-2"
    style="height: 100%"
  >
    <div style="height: calc(100% - 46px); overflow-y: scroll">
      <QueriesList
        v-if="isQueriesListOpened"
        :exclude-ids="layout.map((item) => item.query_id)"
        @select="onSelectQuery"
      />
      <VueDraggableNext
        v-else
        :list="layout"
      >
        <div
          v-for="item in layout"
          :key="item.query_id"
          class="ivu-card ivu-card-bordered cursor-move mb-2"
        >
          <div class="ivu-card-body d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
              <div class="d-flex flex-column me-2">
                <i
                  class="ion ion-md-arrow-dropup"
                  @click.prevent="moveItem(item, -1)"
                />
                <i
                  class="ion ion-md-arrow-dropdown"
                  @click.prevent="moveItem(item, 1)"
                />
              </div>
              <h3 class="text-muted">
                {{ item.title }}
              </h3>
            </div>
            <div class="d-flex align-items-center">
              <select v-model="item.size">
                <option
                  v-for="option in sizeOptions"
                  :key="option.value"
                  :value="option.value"
                >
                  {{ option.label }}
                </option>
              </select>
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
    <div class="footer">
      <VButton
        long
        type="default"
        :icon="isQueriesListOpened ? 'md-close' : 'md-add'"
        @click="toggleQueriesList"
      >
        {{ isQueriesListOpened ? 'Cancel' : 'Add query' }}
      </VButton>
    </div>
  </div>
</template>

<script>
import QueriesList from 'queries/components/list'
import { VueDraggableNext } from 'vue-draggable-next'

export default {
  name: 'DashboardEditor',
  components: {
    QueriesList,
    VueDraggableNext
  },
  props: {
    layout: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      isQueriesListOpened: false
    }
  },
  computed: {
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
    moveItem (item, step) {
      const index = this.layout.indexOf(item)

      this.layout.splice(index, 1)
      this.layout.splice(index + step, 0, item)
    },
    removeItem (item) {
      const index = this.layout.indexOf(item)

      this.layout.splice(index, 1)
    },
    onSelectQuery (query) {
      this.isQueriesListOpened = false

      this.layout.push({ query_id: query.id, size: 50, title: query.name })
    },
    toggleQueriesList () {
      this.isQueriesListOpened = !this.isQueriesListOpened
    }
  }
}
</script>

<style lang="scss" scoped>
.footer {
  width: 100%;
  position: sticky;
  bottom: 0;
  left: 0;
  border-top: 1px solid #e8e8e8;
  padding-top: 10px;
  text-align: right;
  background: #fff;
}

.ion-md-arrow-dropup, .ion-md-arrow-dropdown {
  cursor: pointer;
}
</style>
