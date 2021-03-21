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
  <QueryTable
    v-else
    :data="data"
    :minimal-pagination="true"
    :columns="columns"
    :default-page-size="10"
    :borderless="true"
    :compact="true"
  />
</template>

<script>
import api from 'api'
import QueryTable from 'queries/components/table'

export default {
  name: 'Board',
  components: {
    QueryTable
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
      data: [],
      columns: []
    }
  },
  mounted () {
    this.loadData()
  },
  methods: {
    loadData () {
      this.isLoading = true

      api.get(`api/run_queries/${this.board.query_id}`).then((result) => {
        this.data = result.data.data
        this.columns = result.data.meta.columns
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
