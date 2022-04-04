<template>
  <div class="row">
    <template
      v-for="item in dashboard.preferences.layout"
      :key="item.query_id"
    >
      <div
        v-if="findQuery(item.query_id)"
        :class="classForSizeMap[item.size[0]]"
        class="p-0"
      >
        <div class="mb-2 mx-1 ivu-card ivu-card-bordered">
          <Board
            :ref="pushBoardRef"
            :item="item"
            :variables="variables"
            :query="findQuery(item.query_id)"
          />
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import Board from './board'

export default {
  name: 'DashboardLayout',
  components: {
    Board
  },
  props: {
    dashboard: {
      type: Object,
      required: true
    },
    variables: {
      type: Object,
      required: false,
      default: () => ({})
    }
  },
  data () {
    return {
      boards: []
    }
  },
  computed: {
    classForSizeMap () {
      return {
        1: 'col-12 col-lg-3',
        2: 'col-12 col-lg-4',
        3: 'col-12 col-lg-6',
        4: 'col-12 col-lg-8',
        5: 'col-12 col-lg-9',
        6: 'col-12 col-lg-12'
      }
    }
  },
  beforeUpdate () {
    this.boards = []
  },
  methods: {
    findQuery (queryId) {
      return this.dashboard.queries.find((query) => query.id === queryId)
    },
    scrollInto (item) {
      const board = this.boards.find((board) => board.item === item)

      if (board) {
        board.$el.parentElement.scrollIntoView({ behavior: 'smooth' })
      }
    },
    pushBoardRef (el) {
      if (el) {
        this.boards.push(el)
      }
    },
    reload (withLoading = true) {
      return Promise.all(this.boards.map((board) => board.loadData(withLoading)))
    }
  }
}
</script>

<style lang="scss">
</style>
