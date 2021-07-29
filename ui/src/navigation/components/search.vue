<template>
  <MSelect
    icon="ios-search"
    size="large"
    :border="false"
    :options="options"
    :focus-first="true"
    :value-function="(option) => [option.value, option.type].join('::')"
    filterable
    label-key="value"
    :with-deselect="false"
    :option-component="optionComponent"
    :remote-function="onSearch"
    @select="onSelect"
  />
</template>

<script>
import { schema } from 'data_resources/scripts/schema'
import { itemsStore, loadItems } from 'reports/scripts/store'
import { formsStore, loadForms } from 'custom_forms/scripts/store'
import throttle from 'view3/src/utils/throttle'
import singularize from 'inflected/src/singularize'
import SearchOption from './search_option'
import transliterate from 'inflected/src/transliterate'

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
  displayOptions () {
    return this.all().slice(0, this.DISPLAY_LIMIT)
  },
  all () {
    return JSON.parse(localStorage.getItem(this.KEY) || '[]')
  }
}

const MAX_RESOURCE_ITEMS = 6
const MAX_ASSET_ITEMS = 8

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
    optionComponent () {
      return SearchOption
    },
    visibleModels () {
      return schema.filter((model) => model.visible).map((model) => {
        return { ...model, normalizedName: transliterate(model.display_name.toLowerCase()) }
      })
    },
    normalizedValue () {
      return transliterate(this.value.toLowerCase().trim())
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
        let array = this.visibleModels.filter((e) => {
          return e.normalizedName.match(new RegExp(`\\b${this.normalizedValue}`))
        })

        if (!array.length) {
          array = this.visibleModels.filter((e) => {
            return e.normalizedName.match(new RegExp(`\\b${this.normalizedValue.replace(/\s["#\w]+$/, '')}`))
          })
        }

        if (!array.length) {
          array = this.visibleModels.filter((e) => {
            return this.normalizedValue.includes(e.normalizedName.replace(/e?s\b/, ''))
          })
        }

        return array.sort((a, b) => a.display_name.length > b.display_name.length ? -1 : 1)
      } else {
        return []
      }
    },
    foundAssets () {
      return this.allAssets.filter((e) => {
        return e.normalizedName.includes(this.normalizedValue)
      }).slice(0, MAX_ASSET_ITEMS)
    },
    allAssets () {
      return [...itemsStore, ...formsStore.map((form) => {
        return { ...form, type: 'form' }
      })].map((item) => {
        return { ...item, normalizedName: transliterate((item.name || item.title).toLowerCase()) }
      })
    },
    pages () {
      return [
        { value: this.i18n.new_query, type: 'new_query' },
        { value: this.i18n.new_dashboard, type: 'new_dashboard' },
        { value: this.i18n.new_alert, type: 'new_alert' },
        { value: this.i18n.new_form, type: 'new_form' }
      ]
    },
    foundPages () {
      return this.pages.filter((e) => e.value.toLowerCase().includes(this.normalizedValue))
    }
  },
  mounted () {
    this.options = recentlySelectedStore.displayOptions()

    this.$nextTick(() => {
      this.$el.querySelector('input').focus()
    })

    setTimeout(() => {
      this.$el.querySelector('input').click()
    }, 200)
  },
  methods: {
    buildItems () {
      const reports = this.foundAssets.map((e) => {
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
        value: `${singularize(model.display_name)} #${this.cleanedValue}`
      }
    },
    buildResourceSearchOptions (model) {
      return {
        type: 'resource_search',
        slug: model.slug,
        query: this.cleanedValue,
        value: `${singularize(model.display_name)} "${this.cleanedValue}"`
      }
    },
    onSelect (option) {
      if (option.type === 'query') {
        this.$router.push({ name: 'query', params: { id: option.id } })
      } else if (option.type === 'dashboard') {
        this.$router.push({ name: 'dashboard', params: { id: option.id } })
      } else if (option.type === 'alert') {
        this.$router.push({ name: 'alert', params: { id: option.id } })
      } else if (option.type === 'form') {
        this.$router.push({ name: 'form', params: { id: option.id } })
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
      } else if (option.type === 'new_alert') {
        this.$router.push({ name: 'new_alert' })
      } else if (option.type === 'new_form') {
        this.$router.push({ name: 'new_form' })
      }

      recentlySelectedStore.push(option)

      this.$emit('selected', option)
    },
    onSearch: throttle(function (value) {
      this.value = value

      if (!this.isLoaded) {
        loadItems()
        loadForms()
      }

      if (this.value.length) {
        this.options = this.buildItems()
      } else {
        this.options = recentlySelectedStore.displayOptions()
      }

      return Promise.resolve()
    }, 200)
  }
}
</script>

<style>
</style>
