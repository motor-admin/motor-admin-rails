<template>
  <div class="row mx-2 mt-3">
    <div class="d-none d-lg-block col-lg-2">
      <template v-if="tags.length">
        <p
          class="fs-4 fw-bold"
          style="margin: 25px 0 5px 0"
        >
          Tags
        </p>
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
        <VButton
          v-if="selectedTags.length"
          type="text"
          icon="md-close"
          class="ms-2 mt-2 bg-transparent"
          size="small"
          @click="clearSelectedTags"
        >
          Clear selection
        </VButton>
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
      <div :style="{ height: 'calc(100vh - 224px)', overflow: 'scroll', position: 'relative', margin: '0 -12px', padding: '0 12px' }">
        <Spin
          v-if="isLoading"
          fix
        />
        <p
          v-else-if="!searchQuery && !selectedTags.length && !paginatedItems.length"
          class="text-center mt-2"
        >
          Looks like you are new here 🙃
        </p>
        <p
          v-if="searchQuery && !paginatedItems.length"
          class="text-center mt-2"
        >
          Not Found
        </p>
        <div
          v-for="item in paginatedItems"
          :key="item.type ? item.type + item.id : 'table' + item.slug"
          class="col-12"
        >
          <ReportItem
            :item="item"
            :item-type="item.type || 'table'"
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
    <div class="d-none d-lg-block col-lg-2 text-end">
      <Dropdown
        trigger="click"
        transfer
      >
        <VButton
          icon="md-add"
          size="large"
        >
          Add New
        </VButton>
        <template #list>
          <DropdownMenu>
            <DropdownItem @click="$router.push({ name: 'new_query' })">
              Query
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: 'new_dashboard' })">
              Dashboard
            </DropdownItem>
            <DropdownItem @click="$router.push({})">
              Form
            </DropdownItem>
            <DropdownItem @click="$router.push({ name: 'new_alert' })">
              Alert
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
    </div>
  </div>
</template>

<script>
import Tabs from 'utils/components/tabs'
import ReportItem from '../components/item'
import { itemsStore, loadItems } from '../scripts/store'
import { schema } from 'data_resources/scripts/schema'

const TYPES_MAP = {
  queries: 'query',
  dashboards: 'dashboard',
  alerts: 'alert',
  tables: 'table'
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
      selectedType: this.$route.name || 'all_resources',
      pageParams: {
        current: 1,
        pageSize: 20,
        pageSizeOpts: [20, 50, 100]
      }
    }
  },
  computed: {
    tabs () {
      const query = this.selectedTags.length ? { tags: this.selectedTags.join(',') } : {}

      return [
        {
          value: 'all_resources',
          label: 'All',
          to: { name: 'all_resources', query }
        },
        {
          value: 'tables',
          label: 'Tables',
          to: { name: 'tables', query }
        },
        {
          value: 'queries',
          label: 'Queries',
          to: { name: 'queries', query }
        },
        {
          value: 'dashboards',
          label: 'Dashboards',
          to: { name: 'dashboards', query }
        },
        {
          value: 'forms',
          label: 'Forms',
          to: { name: 'forms', query }
        },
        {
          value: 'alerts',
          label: 'Alerts',
          to: { name: 'alerts', query }
        }
      ]
    },
    items () {
      if (this.selectedType === 'all_resources') {
        return [...itemsStore, ...this.tableItems]
      } else if (this.selectedType === 'tables') {
        return this.tableItems
      } else {
        return itemsStore.filter((item) => {
          return item.type === TYPES_MAP[this.selectedType]
        })
      }
    },
    tableItems () {
      return schema.filter((model) => model.visible)
    },
    searchPlaceholder () {
      return 'Search'
    },
    filteredItems () {
      return this.items.filter((item) => {
        return (
          !this.selectedTags.length ||
          this.selectedTags.every((tag) => item.tags?.includes(tag))
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
        (item.tags || []).forEach((tag) => {
          acc[tag] ||= { name: tag, count: 0 }

          if (this.filteredItems.includes(item)) {
            acc[tag].count++
          }
        })

        return acc
      }, this.selectedTags.reduce((acc, tag) => {
        acc[tag] = { name: tag, count: 0 }

        return acc
      }, {})))
    }
  },
  watch: {
    '$route' (to, from) {
      this.selectedType = to.name || 'all_resources'

      if (to.query?.tags) {
        this.selectedTags = to.query.tags.split(',')
      } else {
        this.selectedTags = []
      }
    }
  },
  mounted () {
    if (this.items.length === 0) {
      this.isLoading = true
    }

    this.loadItems().finally(() => {
      this.isLoading = false
    })

    if (this.$route.query?.tags) {
      this.selectedTags = this.$route.query.tags.split(',')
    }
  },
  methods: {
    loadItems,
    reloadItems () {
      this.isLoading = true

      this.loadItems().finally(() => {
        this.isLoading = false
      })
    },
    clearSelectedTags () {
      this.selectedTags = []

      this.$router.push({ query: {} })
    },
    toggleTag (tag) {
      if (this.selectedTags.includes(tag)) {
        const index = this.selectedTags.indexOf(tag)

        this.selectedTags.splice(index, 1)
      } else {
        this.selectedTags.push(tag)
      }

      if (this.selectedTags.length) {
        this.$router.push({ query: { tags: this.selectedTags.join(',') } })
      } else {
        this.$router.push({ query: {} })
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
