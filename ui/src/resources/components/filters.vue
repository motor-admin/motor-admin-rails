<template>
  <div
    style="min-height: calc(100% - 53px)"
    @keydown.enter="$emit('apply', clearedFilters)"
  >
    <div
      :key="dataFilters.length"
      class="pt-2"
    >
      <template
        v-for="(filter, index) in dataFilters"
        :key="index"
      >
        <FilterItem
          v-if="filter !== 'OR'"
          :filter="filter"
          :model="model"
          style="margin: -4px 0"
          @remove="removeFilter"
          @update:filter="updateFilter(filter, $event)"
        />
        <Tag
          v-if="filter === 'OR'"
          color="volcano"
          class="ms-1 my-0"
          @click="toggleOr(index)"
        >
          {{ filter }}
        </Tag>
        <Tag
          v-else-if="index !== dataFilters.length - 1 && dataFilters[index + 1] !== 'OR'"
          color="blue"
          class="m-0"
          @click="toggleOr(index)"
        >
          AND
        </Tag>
      </template>
      <div class="pb-2 pt-3 text-center">
        <VButton
          icon="md-add"
          type="text"
          @click="addFilter"
        >
          Add Filter
        </VButton>
      </div>
    </div>
  </div>
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
import FilterItem from './filters_item'

const defaultFilterValues = {
  '': {
    eq: ''
  }
}

export default {
  name: 'ResourceFilters',
  components: {
    FilterItem
  },
  props: {
    model: {
      type: Object,
      required: true
    },
    filters: {
      type: [Array, Object],
      required: false,
      default: () => ({})
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
  mounted () {
    this.dataFilters = [...this.filters]

    if (!this.dataFilters.length) {
      this.addFilter()
    }
  },
  methods: {
    addFilter () {
      this.dataFilters.push({ ...defaultFilterValues })
    },
    toggleOr (index) {
      if (this.dataFilters[index] === 'OR') {
        this.dataFilters.splice(index, 1)
      } else {
        this.dataFilters.splice(index + 1, 0, 'OR')
      }
    },
    updateFilter (filter, newFilter) {
      const index = this.dataFilters.indexOf(filter)

      this.dataFilters.splice(index, 1, newFilter)
    },
    removeFilter (filter) {
      const index = this.dataFilters.indexOf(filter)

      this.dataFilters.splice(index, 1)

      if (this.dataFilters[index] === 'OR') {
        this.dataFilters.splice(index, 1)
      }

      if (this.dataFilters[0] === 'OR') {
        this.dataFilters.splice(0, 1)
      }

      if (this.dataFilters[this.dataFilters.length - 1] === 'OR') {
        this.dataFilters.splice(this.dataFilters.length - 1, 1)
      }
    }
  }
}
</script>

<style lang="scss">

</style>
