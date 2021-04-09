<template>
  <AutoComplete
    icon="ios-search"
    size="large"
    :border="false"
    @on-change="onSearch"
    @on-select="onSelect"
  >
    <VOption
      v-for="(option, index) in options"
      :key="index"
      :value="option.value"
      :label="option.value"
    >
      <Icon
        :type="iconClasses[option.type]"
        style="width: 20px"
      />
      {{ option.value }}
    </VOption>
  </AutoComplete>
</template>

<script>
import { schema } from 'utils/scripts/schema'
import { itemsStore, loadItems } from 'reports/scripts/store'
import { titleize } from 'utils/scripts/string'
import throttle from 'view3/src/utils/throttle'

const recentlySelectedStore = {
  get KEY () {
    return 'search:recentlySelected'
  },
  get DISPLAY_LIMIT () {
    return 6
  },
  push (item) {
    const items = this.all()

    const index = items.findIndex(e => e.value === item.value && e.type === item.type)

    if (index !== -1) {
      items.splice(index, 1)
    }

    localStorage.setItem(this.KEY, JSON.stringify([item, ...items].slice(0, 20)))
  },
  display () {
    return this.all().slice(0, this.DISPLAY_LIMIT)
  },
  all () {
    return JSON.parse(localStorage.getItem(this.KEY) || '[]')
  }
}

const MAX_RESOURCE_ITEMS = 6
const MAX_REPORT_ITEMS = 8

export default {
  name: 'NavigationSearch',
  emits: ['selected'],
  data () {
    return {
      value: '',
      options: [],
      isLoaded: false
    }
  },
  computed: {
    iconClasses () {
      return {
        resource: 'md-share-alt',
        query: 'md-list',
        dashboard: 'md-analytics',
        resource_search: 'md-search',
        resource_id: 'md-open',
        new_query: 'md-create',
        new_dashboard: 'md-create'
      }
    },
    normalizedValue () {
      return this.value.toLowerCase().trim()
    },
    withId () {
      return this.foundResources.length && this.cleanedValue.match(/^\d+$/) && parseInt(this.cleanedValue) > 0
    },
    cleanedValue () {
      return this.foundResources.reduce((acc, e) => {
        const words = new Set([...e.display_name.toLowerCase().split(' '), ...e.name.split('_')])

        return [...words].reduce((a, b) => {
          return a.replace(b, '')
        }, acc).trim()
      }, this.normalizedValue).replace(/[#"]/g, '')
    },
    foundResources () {
      if (this.value) {
        let array = schema.filter((e) => {
          const name = e.display_name.toLowerCase()

          return !!name.match(new RegExp(`\\b${this.normalizedValue}`))
        })

        if (!array.length) {
          array = schema.filter((e) => {
            const name = e.display_name.toLowerCase()

            return !!name.match(new RegExp(`\\b${this.normalizedValue.replace(/\s["#\w]+$/, '')}`))
          })
        }

        if (!array.length) {
          array = schema.filter((e) => {
            const name = e.display_name.toLowerCase()

            return this.normalizedValue.includes(name.replace(/e?s\b/, ''))
          })
        }

        return array.sort((a, b) => a.display_name.length > b.display_name.length ? -1 : 1)
      } else {
        return []
      }
    },
    foundReports () {
      return itemsStore.filter((e) => {
        return (e.name || e.title).toLowerCase().includes(this.normalizedValue)
      }).slice(0, MAX_REPORT_ITEMS)
    },
    pages () {
      return [
        { value: 'New Query', type: 'new_query' },
        { value: 'New Dashboard', type: 'new_dashboard' }
      ]
    },
    foundPages () {
      return this.pages.filter((e) => e.value.toLowerCase().includes(this.normalizedValue))
    }
  },
  mounted () {
    this.options = recentlySelectedStore.display()

    this.$nextTick(() => {
      this.$el.querySelector('input').focus()
      this.$el.querySelector('input').click()
    })
  },
  methods: {
    buildItems () {
      const reports = this.foundReports.map((e) => {
        return { value: e.title || e.name, type: e.type, id: e.id }
      })

      const resources = [...this.foundResources].reverse().map((e) => {
        return [
          this.withId && this.buildResourceIdOptions(e),
          !this.withId && this.withQuery(e) && this.buildResourceSearchOptions(e),
          { type: 'resource', slug: e.slug, value: e.display_name }
        ].filter(Boolean)
      }).flat().slice(0, MAX_RESOURCE_ITEMS)

      let items = [
        ...resources,
        ...reports,
        ...this.foundPages
      ]

      if (items.length === 0) {
        items =
          recentlySelectedStore.all().filter((e) => e.type === 'resource_search').map((e) => {
            return {
              ...e,
              value: e.value.replace(/".*"/, `"${this.cleanedValue}"`),
              query: this.cleanedValue
            }
          })

        items = items.filter((v, i, a) => items.findIndex((e) => e.slug === v.slug) === i)
      }

      return items.sort((a, b) => a.value.toLowerCase() === this.normalizedValue ? -1 : 1)
    },
    withQuery (model) {
      return this.foundResources.length &&
        this.cleanedValue &&
        this.normalizedValue.includes(' ') &&
        !model.display_name.toLowerCase().match(new RegExp(`\\b${this.normalizedValue}`))
    },
    buildResourceIdOptions (model) {
      return {
        type: 'resource_id',
        slug: model.slug,
        id: this.cleanedValue,
        value: `${titleize(model.name)} #${this.cleanedValue}`
      }
    },
    buildResourceSearchOptions (model) {
      return {
        type: 'resource_search',
        slug: model.slug,
        query: this.cleanedValue,
        value: `${titleize(model.name)} "${this.cleanedValue}"`
      }
    },
    onSelect (value) {
      const option = this.options.find((e) => e.value === value)

      if (option.type === 'query') {
        this.$router.push({ name: 'query', params: { id: option.id } })
      } else if (option.type === 'dashboard') {
        this.$router.push({ name: 'dashboard', params: { id: option.id } })
      } else if (option.type === 'resource') {
        this.$router.push({ name: 'resources', params: { fragments: [option.slug] } })
      } else if (option.type === 'resource_id') {
        this.$router.push({ name: 'resources', params: { fragments: [option.slug, option.id] } })
      } else if (option.type === 'resource_search') {
        this.$router.push({ name: 'resources', params: { fragments: [option.slug] }, query: { q: option.query } })
      } else if (option.type === 'new_query') {
        this.$router.push({ name: 'new_query' })
      } else if (option.type === 'new_dashboard') {
        this.$router.push({ name: 'new_dashboard' })
      }

      recentlySelectedStore.push(option)

      this.$emit('selected', option)
    },
    onSearch: throttle(function (value) {
      this.value = value

      if (!this.isLoaded) {
        loadItems()
      }

      if (this.value.length > 1) {
        this.options = this.buildItems()
      } else {
        this.options = recentlySelectedStore.display()
      }
    }, 200)
  }
}
</script>

<style>
</style>
