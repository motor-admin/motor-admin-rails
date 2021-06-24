<template>
  <div
    class="pt-2"
  >
    <template
      v-for="([filter, key], index) in filtersWithKeys"
      :key="key"
    >
      <FilterItem
        v-if="filter !== 'OR'"
        :filter="filter"
        :model="model"
        style="margin: -4px 0"
        @remove="removeFilter"
        @update:filter="updateFilter(key, $event)"
      />
      <div style="max-width: 42px; text-align: center">
        <Tag
          v-if="filter === 'OR'"
          color="volcano"
          class="ms-1 my-0"
          @click="toggleOr(index)"
        >
          {{ i18n[filter.toLowerCase()]?.toUpperCase() }}
        </Tag>
        <Tag
          v-else-if="index !== filters.length - 1 && filters[index + 1] !== 'OR'"
          color="blue"
          class="m-0"
          @click="toggleOr(index)"
        >
          {{ i18n['and']?.toUpperCase() }}
        </Tag>
      </div>
    </template>
    <div class="pb-2 pt-3 text-center">
      <VButton
        icon="md-add"
        type="text"
        @click="addFilter"
      >
        {{ i18n['add_filter'] }}
      </VButton>
    </div>
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
      default: () => []
    }
  },
  emits: ['update:filters'],
  data () {
    return {
      filtersWithKeys: []
    }
  },
  created () {
    this.filtersWithKeys = this.filters.map((e) => [e, Math.random()])

    if (!this.filters.length) {
      this.addFilter()
    }
  },
  methods: {
    updateFilters () {
      this.$emit('update:filters', this.filtersWithKeys.map((e) => e[0]))
    },
    addFilter () {
      this.filtersWithKeys.push([{ ...defaultFilterValues }, Math.random()])

      this.updateFilters()
    },
    toggleOr (index) {
      if (this.filtersWithKeys[index][0] === 'OR') {
        this.filtersWithKeys.splice(index, 1)
      } else {
        this.filtersWithKeys.splice(index + 1, 0, ['OR', Math.random()])
      }

      this.updateFilters()
    },
    updateFilter (key, newFilter) {
      const index = this.filtersWithKeys.findIndex(([_, filterKey]) => filterKey === key)

      this.filtersWithKeys.splice(index, 1, [newFilter, key])

      this.updateFilters()
    },
    removeFilter (filter) {
      const index = this.filters.indexOf(filter)

      this.filtersWithKeys.splice(index, 1)

      if (this.filtersWithKeys[index]?.[0] === 'OR') {
        this.filtersWithKeys.splice(index, 1)
      }

      if (this.filtersWithKeys[0]?.[0] === 'OR') {
        this.filtersWithKeys.splice(0, 1)
      }

      if (this.filtersWithKeys[this.filtersWithKeys.length - 1]?.[0] === 'OR') {
        this.filtersWithKeys.splice(this.filtersWithKeys.length - 1, 1)
      }

      this.updateFilters()
    }
  }
}
</script>

<style lang="scss">
</style>
