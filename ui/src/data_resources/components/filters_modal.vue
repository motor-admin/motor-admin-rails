<template>
  <Filters
    v-model:filters="dataFilters"
    :model="model"
    class="filters"
    @keydown.enter="$emit('apply', clearedFilters)"
  />
  <div class="drawer-footer">
    <VButton
      class="float-left"
      @click="$emit('cancel')"
    >
      Cancel
    </VButton>
    <VButton
      @click="$emit('apply', [])"
    >
      Clear All
    </VButton>
    <VButton
      class="ms-2"
      type="primary"
      @click="$emit('apply', clearedFilters)"
    >
      Apply
    </VButton>
  </div>
</template>

<script>
import Filters from './filters'

export default {
  name: 'ResourceFiltersModal',
  components: {
    Filters
  },
  props: {
    model: {
      type: Object,
      required: true
    },
    filters: {
      type: [Array, Object],
      required: false,
      default: () => []
    }
  },
  emits: ['apply', 'cancel'],
  data () {
    return {
      count: 0,
      dataFilters: []
    }
  },
  computed: {
    clearedFilters () {
      return this.dataFilters.filter((f) => {
        return f === 'OR' || !!Object.keys(f)[0]
      })
    }
  },
  created () {
    this.dataFilters = [...this.filters]
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.filters {
  @media screen and (max-width: $breakpoint-md) {
    min-height: calc(100% - 53px);
  }
}
</style>
