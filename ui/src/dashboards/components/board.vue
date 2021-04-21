<template>
  <Spin
    v-if="!query"
    fix
  />
  <template v-else>
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
            <b>{{ query.name }}</b>
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
            placeholder="Search..."
            @keydown.enter="searchQuery = searchInput"
          />
        </div>
      </div>
    </div>
    <div
      class="ivu-card-body p-0"
      style="height: 387px"
    >
      <Spin
        v-if="isLoading"
        fix
      />
      <div
        v-if="data.length === 1 && data[0].length === 1"
        class="d-flex align-items-center justify-content-center flex-column"
        style="height: 100%"
      >
        <h1 style="font-size: 60px">
          {{ data[0][0] }}
        </h1>
        <h2>
          {{ columns[0].name }}
        </h2>
      </div>
      <QueryResult
        v-else
        :data="filteredData"
        :title="query.name"
        :minimal-pagination="true"
        :errors="errors"
        :preferences="query.preferences"
        :columns="columns"
        :default-page-size="10"
        :borderless="true"
        :with-settings="false"
        :compact="true"
      />
    </div>
  </template>
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
    query: {
      type: Object,
      required: false,
      default: null
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
    queryVariables () {
      return (this.query.preferences.variables || []).reduce((acc, variable) => {
        acc[variable.name] = this.variables[variable.name] || variable.default_value

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
      return (!this.query.preferences.visualization || this.query.preferences.visualization === 'table') && this.data.length > 10
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
