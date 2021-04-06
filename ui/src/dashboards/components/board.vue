<template>
  <Spin
    v-if="isLoading"
    fix
  />
  <div
    v-if="data.length === 1 && data[0].length === 1"
    class="d-flex align-items-center justify-content-center"
    style="height: 100%"
  >
    <h1 style="font-size: 60px">
      {{ data[0][0] }}
    </h1>
  </div>
  <QueryResult
    v-else
    :data="data"
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
      isLoading: false,
      errors: [],
      data: [],
      columns: [],
      preferences: {}
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    loadData () {
      this.isLoading = true

      api.get(`api/run_queries/${this.board.query_id}`).then((result) => {
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
