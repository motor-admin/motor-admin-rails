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
          :to="{ name: 'query', params: { id: board.query_id } }"
          class="text-dark"
        >
          <b>{{ board.title }}</b>
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
      :title="board.title"
      :minimal-pagination="true"
      :errors="errors"
      :preferences="preferences"
      :columns="columns"
      :default-page-size="10"
      :borderless="true"
      :with-settings="false"
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
    board: {
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
      columns: [],
      preferences: {}
    }
  },
  computed: {
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
      return (!this.preferences.visualization || this.preferences.visualization === 'table') && this.data.length > 10
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    loadData () {
      this.isLoading = true

      return api.get(`api/run_queries/${this.board.query_id}`).then((result) => {
        this.errors = []
        this.data = result.data.data
        this.preferences = result.data.preferences
        this.columns = result.data.meta.columns
      }).catch((error) => {
        this.errors = error.response.data?.errors
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
