<template>
  <Spin
    v-if="isLoading"
    fix
  />
  <div class="row mx-2 mt-3 mb-2">
    <div class="col-2">
      <h1 class="">
        Reports
      </h1>
    </div>
    <div class="col-10 col-lg-10 text-end">
      <VButton
        icon="md-add"
        size="large"
        type="default"
        class="me-2"
        :to="{ name: 'new_dashboard' }"
      >
        Add Dashboard
      </VButton>
      <VButton
        icon="md-add"
        size="large"
        type="default"
        :to="{ name: 'new_query' }"
      >
        Add Query
      </VButton>
    </div>
  </div>
  <div class="row mx-2">
    <div class="d-none d-lg-block col-lg-2">
      <template v-if="tags.length">
        <h3 style="margin: 25px 0 5px 0">
          Tags
        </h3>
        <Tag
          v-for="tag in tags"
          :key="tag"
          type="dot"
          size="large"
          :color="selectedTags.includes(tag.name) ? 'primary' : 'light'"
          @click="toggleTag(tag.name)"
        >
          {{ tag.name }} ({{ tag.count }})
        </Tag>
      </template>
    </div>
    <div class="col-12 col-lg-8">
      <Tabs
        v-model="selectedType"
        :tabs="tabs"
      />
      <VInput
        v-model="searchQuery"
        search
        :placeholder="searchPlaceholder"
        size="large"
        class="mb-2"
      />
      <div :style="{ height: 'calc(100vh - 274px)', overflow: 'scroll' }">
        <div
          v-for="item in paginatedItems"
          :key="item.type + item.id"
          class="col-12"
        >
          <ReportItem
            :item="item"
            @remove="reloadItems"
          />
        </div>
      </div>
      <div class="text-center bg-white rounded border mb-2 p-1">
        <Pagination
          :current="pageParams.current"
          :total="filteredItems.length"
          :page-size="pageParams.pageSize"
          :page-size-opts="pageParams.pageSizeOpts"
          size="small"
          show-sizer
          show-elevator
          show-total
          @update:current="pageParams.current = $event"
          @update:page-size="pageParams.pageSize = $event"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Tabs from 'utils/components/tabs'
import ReportItem from '../components/item'
import { itemsStore, loadItems } from '../scripts/store'

const TYPES_MAP = {
  queries: 'query',
  dashboards: 'dashboard'
}

export default {
  name: 'ReportsIndex',
  components: {
    Tabs,
    ReportItem
  },
  data () {
    return {
      isLoading: false,
      searchQuery: '',
      selectedTags: [],
      selectedType: this.$route.params.type || 'all',
      pageParams: {
        current: 1,
        pageSize: 20,
        pageSizeOpts: [20, 50, 100]
      }
    }
  },
  computed: {
    tabs () {
      return [
        {
          value: 'all',
          label: 'All',
          to: { name: 'reports' }
        },
        {
          value: 'queries',
          label: 'Queries',
          to: { name: 'reports', params: { type: 'queries' } }
        },
        {
          value: 'dashboards',
          label: 'Dashboards',
          to: { name: 'reports', params: { type: 'dashboards' } }
        }
      ]
    },
    items () {
      return itemsStore.filter((item) => {
        return this.selectedType === 'all' || item.type === TYPES_MAP[this.selectedType]
      })
    },
    searchPlaceholder () {
      return 'Search'
    },
    filteredItems () {
      return this.items.filter((item) => {
        return (
          !this.selectedTags.length ||
          this.selectedTags.every((tag) => item.tags.includes(tag))
        ) && (
          !this.searchQuery ||
          (item.name || item.title).toLowerCase().includes(this.searchQuery.toLowerCase())
        )
      })
    },
    paginatedItems () {
      const pageSize = this.pageParams.pageSize

      return this.filteredItems.slice((this.pageParams.current - 1) * pageSize, this.pageParams.current * pageSize)
    },
    tags () {
      return Object.values(this.items.reduce((acc, item) => {
        item.tags.forEach((tag) => {
          acc[tag] ||= { name: tag, count: 0 }

          if (this.filteredItems.includes(item)) {
            acc[tag].count++
          }
        })

        return acc
      }, {}))
    }
  },
  watch: {
    '$route' (to, from) {
      this.selectedType = to.params.type || 'all'
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
    loadItems,
    reloadItems () {
      this.isLoading = true

      this.loadItems().finally(() => {
        this.isLoading = false
      })
    },
    toggleTag (tag) {
      if (this.selectedTags.includes(tag)) {
        const index = this.selectedTags.indexOf(tag)

        this.selectedTags.splice(index, 1)
      } else {
        this.selectedTags.push(tag)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-tag {
  font-size: 14px;
  width: 100%
}
</style>
