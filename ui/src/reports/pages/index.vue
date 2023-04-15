<template>
  <div class="row mx-0 mx-md-2 mt-3 mb-2">
    <div class="col-2">
      <h1>
        {{ i18n['reports'] }}
      </h1>
    </div>
    <div class="col-10 col-lg-10 text-end d-none d-md-block">
      <VButton
        v-if="$can('create', 'Motor::Query')"
        icon="md-add"
        size="large"
        type="default"
        class="me-2"
        :to="{ name: 'new_query' }"
      >
        {{ i18n['add_query'] }}
      </VButton>
      <VButton
        v-if="$can('create', 'Motor::Dashboard')"
        icon="md-add"
        size="large"
        type="default"
        class="me-2"
        :to="{ name: 'new_dashboard' }"
      >
        {{ i18n['add_dashboard'] }}
      </VButton>
      <VButton
        v-if="$can('create', 'Motor::Alert')"
        icon="md-add"
        size="large"
        type="default"
        :to="{ name: 'new_alert' }"
      >
        {{ i18n['add_alert'] }}
      </VButton>
    </div>
  </div>
  <div class="row mx-0 mx-md-2">
    <div class="d-none d-lg-block col-lg-2">
      <TagsNav
        v-model:selected-tags="selectedTags"
        :taggable-items="items"
        :taggable-filtered-items="filteredItems"
        @update:selected-tags="onTagsChange"
      />
    </div>
    <div class="col-12 col-lg-8">
      <Tabs
        v-model="selectedType"
        :tabs="tabs"
      />
      <VInput
        v-model="searchQuery"
        search
        :placeholder="i18n['search']"
        size="large"
        class="mb-2"
        @update:model-value="[pageParams.current = 1, updateQueryParams()]"
      />
      <div
        ref="table"
        :style="{ height: 'calc(var(--vh, 100vh) - 274px)', overflowY: 'auto', position: 'relative' }"
      >
        <Spin
          v-if="isLoading"
          fix
        />
        <div
          v-else-if="!searchQuery && !selectedTags.length && !paginatedItems.length"
          class="text-center mt-2"
        >
          <div class="mb-3">
            {{ i18n['looks_like_you_are_new_here'] }}
          </div>
          <VButton
            v-if="selectedType === 'dashboards' && $can('create', 'Motor::Dashboard')"
            icon="md-add"
            size="large"
            type="default"
            class="me-2"
            :to="{ name: 'new_dashboard' }"
          >
            {{ i18n['add_dashboard'] }}
          </VButton>
          <VButton
            v-else-if="selectedType === 'alerts' && $can('create', 'Motor::Alert')"
            icon="md-add"
            size="large"
            type="default"
            :to="{ name: 'new_alert' }"
          >
            {{ i18n['add_alert'] }}
          </VButton>
          <VButton
            v-else
            icon="md-add"
            size="large"
            type="default"
            class="me-2"
            :to="{ name: 'new_query' }"
          >
            {{ i18n['add_query'] }}
          </VButton>
        </div>
        <p
          v-if="searchQuery && !paginatedItems.length"
          class="text-center mt-2"
        >
          {{ i18n['not_found'] }}
        </p>
        <div
          v-for="item in paginatedItems"
          :key="item.type + item.id"
          class="col-12"
        >
          <ReportItem
            :item="item"
            :item-type="item.type"
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
          @update:current="[pageParams.current = $event, updateQueryParams()]"
          @update:page-size="pageParams.pageSize = $event"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Tabs from 'utils/components/tabs'
import TagsNav from 'tags/components/navigation'
import ReportItem from '../components/item'
import { itemsStore, loadItems } from '../scripts/store'

const TYPES_MAP = {
  queries: 'query',
  dashboards: 'dashboard',
  alerts: 'alert'
}

function pushTableScrollState () {
  history.replaceState({
    ...history.state,
    tableScrollTop: this.$refs.table.scrollTop,
    tableScrollLeft: this.$refs.table.scrollLeft
  }, document.title, location.href)
}

export default {
  name: 'ReportsIndex',
  components: {
    Tabs,
    TagsNav,
    ReportItem
  },
  beforeRouteUpdate: pushTableScrollState,
  beforeRouteLeave: pushTableScrollState,
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
    normalizedQueryParams () {
      const params = {}

      if (this.selectedTags.length) {
        params.tags = this.selectedTags.join(',')
      }

      if (this.searchQuery) {
        params.q = this.searchQuery
      }

      if (this.pageParams.current > 1) {
        params.page = this.pageParams.current
      }

      if (this.pageParams.pageSize !== 20) {
        params.per_page = this.pageParams.pageSize
      }

      return params
    },
    tabs () {
      const query = this.normalizedQueryParams

      return [
        {
          value: 'all',
          label: this.i18n.all,
          to: { name: 'reports', query }
        },
        this.$can('read', 'Motor::Query') && {
          value: 'queries',
          label: this.i18n.queries,
          to: { name: 'reports', params: { type: 'queries' }, query }
        },
        this.$can('read', 'Motor::Dashboard') && {
          value: 'dashboards',
          label: this.i18n.dashboards,
          to: { name: 'reports', params: { type: 'dashboards' }, query }
        },
        this.$can('read', 'Motor::Alert') && {
          value: 'alerts',
          label: this.i18n.alerts,
          to: { name: 'reports', params: { type: 'alerts' }, query }
        }
      ].filter(Boolean)
    },
    items () {
      return itemsStore.filter((item) => {
        return this.selectedType === 'all' || item.type === TYPES_MAP[this.selectedType]
      })
    },
    filteredItems () {
      return this.items.filter((item) => {
        return (
          !this.selectedTags.length ||
          this.selectedTags.every((tag) => item.tags.some((t) => t.name === tag))
        ) && (
          !this.searchQuery ||
          (item.name || item.title).toLowerCase().includes(this.searchQuery.toLowerCase())
        )
      })
    },
    paginatedItems () {
      const pageSize = this.pageParams.pageSize

      return this.filteredItems.slice((this.pageParams.current - 1) * pageSize, this.pageParams.current * pageSize)
    }
  },
  watch: {
    '$route' (to, from) {
      this.selectedType = to.params.type || 'all'

      if (to.query?.tags) {
        this.selectedTags = to.query.tags.split(',')
      } else {
        this.selectedTags = []
      }

      if (to.query?.q) {
        this.searchQuery = to.query?.q
      }
    },
    selectedType () {
      this.$refs.table.scrollTop = 0
    }
  },
  mounted () {
    if (this.items.length === 0) {
      this.isLoading = true
    }

    this.loadItems().finally(() => {
      this.isLoading = false
    })

    if (typeof history.state.tableScrollTop === 'number') {
      this.$nextTick(() => {
        this.$refs.table.scrollTop = history.state.tableScrollTop
        this.$refs.table.scrollLeft = history.state.tableScrollLeft
      })
    }

    if (this.$route.query?.tags) {
      this.selectedTags = this.$route.query.tags.split(',')
    }

    if (this.$route.query?.q) {
      this.searchQuery = this.$route.query?.q
    }

    if (this.$route.query?.page) {
      this.pageParams.current = this.$route.query.page
    }

    if (this.$route.query?.per_page) {
      this.pageParams.pageSize = this.$route.query.per_page
    }
  },
  methods: {
    loadItems,
    onTagsChange (value) {
      this.selectedTags = value

      this.updateQueryParams()
    },
    updateQueryParams () {
      this.$router.replace({ query: this.normalizedQueryParams })
    },
    reloadItems () {
      this.isLoading = true

      this.loadItems().finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
