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
      />
      <div :style="{ height: 'calc(var(--vh, 100vh) - 274px)', overflow: 'scroll', position: 'relative', margin: '0 -12px', padding: '0 12px' }">
        <Spin
          v-if="isLoading"
          fix
        />
        <p
          v-else-if="!searchQuery && !selectedTags.length && !paginatedItems.length"
          class="text-center mt-2"
        >
          {{ i18n['looks_like_you_are_new_here'] }}
        </p>
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
          @update:current="pageParams.current = $event"
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

export default {
  name: 'ReportsIndex',
  components: {
    Tabs,
    TagsNav,
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
      const query = this.selectedTags.length ? { tags: this.selectedTags.join(',') } : {}

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
    onTagsChange (value) {
      this.selectedTags = value

      if (this.selectedTags.length) {
        this.$router.push({ query: { tags: this.selectedTags.join(',') } })
      } else {
        this.$router.push({ query: {} })
      }
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
