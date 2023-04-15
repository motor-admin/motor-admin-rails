<template>
  <div class="row mx-0 mx-md-2 mt-3 mb-2">
    <div class="col-2">
      <h1 class="">
        {{ i18n['forms'] }}
      </h1>
    </div>
    <div class="col-10 col-lg-10 text-end">
      <VButton
        v-if="$can('create', 'Motor::Form')"
        icon="md-add"
        size="large"
        type="default"
        :to="{ name: 'new_form' }"
      >
        {{ i18n['add_form'] }}
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
        :style="{ height: 'calc(var(--vh, 100vh) - 219px)', overflowY: 'auto', position: 'relative' }"
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
            v-if="$can('create', 'Motor::Form')"
            icon="md-add"
            size="large"
            type="default"
            :to="{ name: 'new_form' }"
          >
            {{ i18n['add_form'] }}
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
          :key="item.id"
          class="col-12"
        >
          <ReportItem
            :item="item"
            :item-type="'form'"
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
import ReportItem from 'reports/components/item'
import TagsNav from 'tags/components/navigation'
import { formsStore, loadForms } from '../scripts/store'

function pushTableScrollState () {
  history.replaceState({
    ...history.state,
    tableScrollTop: this.$refs.table.scrollTop,
    tableScrollLeft: this.$refs.table.scrollLeft
  }, document.title, location.href)
}

export default {
  name: 'FormsIndex',
  components: {
    ReportItem,
    TagsNav
  },
  beforeRouteUpdate: pushTableScrollState,
  beforeRouteLeave: pushTableScrollState,
  data () {
    return {
      isLoading: false,
      searchQuery: '',
      selectedTags: [],
      pageParams: {
        current: 1,
        pageSize: 20,
        pageSizeOpts: [20, 50, 100]
      }
    }
  },
  computed: {
    items () {
      return formsStore
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
      if (to.query?.tags) {
        this.selectedTags = to.query.tags.split(',')
      } else {
        this.selectedTags = []
      }

      if (to.query?.q) {
        this.searchQuery = to.query?.q
      }
    }
  },
  mounted () {
    loadForms()

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
    updateQueryParams () {
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

      this.$router.replace({ query: params })
    },
    onTagsChange (value) {
      this.selectedTags = value

      this.updateQueryParams()
    },
    reloadItems () {
      this.isLoading = true

      loadForms().finally(() => {
        this.isLoading = false
      })
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
