<template>
  <div
    class="ivu-card-head"
    style="padding: 0px 16px"
  >
    <div class="row">
      <div
        class="d-flex align-items-center"
        :class="withSearch ? 'col-8' : 'col-12'"
        style="padding: 10px 8px"
      >
        <RouterLink
          :to="{ name: 'query', params: { id: query.id } }"
          class="text-dark"
        >
          <b>{{ item.title || query.name }}</b>
        </RouterLink>
      </div>
      <div
        v-if="withSearch"
        class="col-4 d-flex align-items-center"
      >
        <VInput
          v-model="searchInput"
          :border="false"
          class="border-0"
          :placeholder="i18n['search_placeholder']"
          @keydown.enter="applySearch"
        />
      </div>
    </div>
  </div>
  <div
    class="ivu-card-body p-0"
    :style="{ height: heightsMap[item.size[2]] }"
  >
    <Spin
      v-if="isLoading"
      fix
    />
    <QueryResult
      :data="filteredData"
      :title="query.name"
      :minimal-pagination="true"
      :errors="errors"
      :loading="isLoading"
      :preferences="query.preferences"
      :columns="columns"
      :default-page-size="pageSizesMap[item.size[2]]"
      :borderless="true"
      :with-settings="false"
      :with-table-toggle="true"
      :compact="true"
    />
  </div>
</template>

<script>
import api from 'api'
import QueryResult from 'queries/components/result'

export default {
  name: 'Board',
  components: {
    QueryResult
  },
  props: {
    variables: {
      type: Object,
      required: false,
      default: () => ({})
    },
    item: {
      type: Object,
      required: false,
      default: null
    },
    query: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      searchQuery: '',
      searchInput: '',
      isLoading: false,
      errors: [],
      data: [],
      columns: []
    }
  },
  computed: {
    heightsMap () {
      return {
        1: '195px',
        2: '387px',
        3: '548px',
        4: '710px'
      }
    },
    pageSizesMap () {
      return {
        1: 4,
        2: 10,
        3: 15,
        4: 20
      }
    },
    queryVariables () {
      return (this.query.preferences.variables || []).reduce((acc, variable) => {
        acc[variable.name] = !this.variables[variable.name] && this.variables[variable.name] !== 0
          ? variable.default_value
          : this.variables[variable.name]

        return acc
      }, {})
    },
    filteredData () {
      if (this.searchQuery) {
        return this.data.filter((row) => {
          return ('"' + row.join('"') + '"').toLowerCase().includes(this.searchQuery.toLowerCase())
        })
      } else {
        return this.data
      }
    },
    withSearch () {
      const visualization = this.query.preferences.visualization

      return (!visualization || ['table', 'markdown', 'value'].includes(visualization)) && this.data.length > (['markdown', 'value'].includes(visualization) ? 1 : 10)
    }
  },
  watch: {
    query (value) {
      if (value) {
        this.loadData()
      }
    }
  },
  mounted () {
    if (this.query) {
      this.loadData()
    }
  },
  methods: {
    applySearch () {
      this.searchQuery = this.searchInput
    },
    loadData () {
      if (!this.isLoading) {
        this.isLoading = true

        return api.get(`run_queries/${this.query.id}`, {
          params: {
            variables: this.queryVariables
          }
        }).then((result) => {
          this.errors = []
          this.data = result.data.data
          this.columns = result.data.meta.columns
        }).catch((error) => {
          this.errors = error.response.data?.errors
        }).finally(() => {
          this.isLoading = false
        })
      }
    }
  }
}
</script>
