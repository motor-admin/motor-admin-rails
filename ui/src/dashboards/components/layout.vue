<template>
  <div class="row">
    <div
      v-for="item in layout"
      :key="item.query_id"
      :class="classForSizeMap[item.size]"
      class="p-0"
    >
      <div class="m-1 ivu-card ivu-card-bordered">
        <Board
          :ref="pushBoardRef"
          :board="item"
        />
      </div>
    </div>
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
    layout: {
      type: Array,
      required: true
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
        50: 'col-12 col-lg-6',
        25: 'col-12 col-lg-3',
        33: 'col-12 col-lg-4',
        66: 'col-12 col-lg-8',
        100: 'col-12'
      }
    }
  },
  beforeUpdate () {
    this.boards = []
  },
  methods: {
    pushBoardRef (el) {
      if (el) {
        this.boards.push(el)
      }
    },
    reload () {
      return Promise.all(this.boards.map((board) => board.loadData()))
    }
  }
}
</script>

<style lang="scss">
</style>
