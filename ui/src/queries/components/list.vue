<template>
  <div style="position: relative">
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
    <div :style="{ height: 'calc(var(--vh, 100vh) - 245px)', overflowY: 'auto' }">
      <p
        v-if="searchQuery && !filteredItems.length"
        class="text-center mt-2"
      >
        {{ i18n['not_found'] }}
      </p>
      <div
        v-for="item in filteredItems"
        :key="item.id"
        class="col-12"
      >
        <div
          class="ivu-card ivu-card-bordered mb-2"
          @click="$emit('select', item)"
        >
          <div class="ivu-card-body py-2">
            <p class="fs-4 fw-bold">
              {{ item.name }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { queriesStore, loadQueries } from 'reports/scripts/store'

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
      return this.i18n.search_query
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

    this.loadQueries().finally(() => {
      this.isLoading = false
    })
  },
  methods: {
    loadQueries
  }
}
</script>

<style lang="scss" scoped>
.ivu-card {
  cursor: pointer;
}
</style>
