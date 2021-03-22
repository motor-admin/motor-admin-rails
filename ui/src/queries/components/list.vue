<template>
  <Spin
    v-if="isLoading"
    fix
  />
  <VInput
    v-model="searchQuery"
    search
    :placeholder="searchPlaceholder"
    size="large"
    class="mb-2"
  />
  <div :style="{ height: 'calc(100vh - 245px)', overflow: 'scroll' }">
    <div
      v-for="item in filteredItems"
      :key="item.id"
      class="col-12"
    >
      <div
        class="ivu-card ivu-card-bordered mb-2"
        @click="$emit('select', item)"
      >
        <div class="ivu-card-body">
          <h3 class="text-muted">
            <Icon :type="item.type === 'query' ? 'md-list' : 'md-add'" />
            {{ item.name || item.title }}
          </h3>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { queriesStore, loadItems } from 'reports/scripts/store'

export default {
  name: 'ReportsIndex',
  props: {
    excludeIds: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['select'],
  data () {
    return {
      isLoading: false,
      searchQuery: ''
    }
  },
  computed: {
    items () {
      return queriesStore
    },
    searchPlaceholder () {
      return 'Search'
    },
    filteredItems () {
      return this.items.filter((item) => {
        return (
          !this.excludeIds.includes(item.id) &&
          (
            !this.searchQuery ||
            item.name.toLowerCase().includes(this.searchQuery.toLowerCase())
          )
        )
      })
    }
  },
  mounted () {
    if (this.items.length === 0) {
      this.isLoading = true
    }

    this.loadItems().finally(() => {
      this.isLoading = false
    })
  },
  methods: {
    loadItems
  }
}
</script>

<style lang="scss" scoped>
.ivu-card {
  cursor: pointer;
}
</style>
