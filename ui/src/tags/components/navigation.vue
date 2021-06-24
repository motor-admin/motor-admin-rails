<template>
  <div v-if="tags.length">
    <p
      class="fs-4 fw-bold"
      style="margin: 25px 0 5px 0"
    >
      {{ i18n['tags'] }}
    </p>
    <Tag
      v-for="tag in tags"
      :key="tag"
      type="dot"
      size="large"
      :color="selectedTags.includes(tag.name) ? 'primary' : 'light'"
      @click="toggleTag(tag.name)"
    >
      {{ tag.name }} ({{ tag.count }})
    </Tag>
    <VButton
      v-if="selectedTags.length"
      type="text"
      icon="md-close"
      class="ms-2 mt-2 bg-transparent"
      size="small"
      @click="clearSelectedTags"
    >
      {{ i18n['clear_selection'] }}
    </VButton>
  </div>
</template>

<script>
export default {
  name: 'TagsNavigation',
  props: {
    taggableItems: {
      type: Array,
      required: true
    },
    taggableFilteredItems: {
      type: Array,
      required: true
    },
    selectedTags: {
      type: Array,
      required: true
    }
  },
  emits: ['update:selectedTags'],
  computed: {
    tags () {
      return Object.values(this.taggableItems.reduce((acc, item) => {
        item.tags.forEach((tag) => {
          acc[tag.name] ||= { ...tag, count: 0 }

          if (this.taggableFilteredItems.includes(item)) {
            acc[tag.name].count++
          }
        })

        return acc
      }, this.selectedTags.reduce((acc, tag) => {
        acc[tag] = { name: tag, count: 0 }

        return acc
      }, {}))).sort((a, b) => a.name > b.name ? 1 : -1)
    }
  },
  methods: {
    clearSelectedTags () {
      this.$emit('update:selectedTags', [])
    },
    toggleTag (tag) {
      if (this.selectedTags.includes(tag)) {
        const index = this.selectedTags.indexOf(tag)

        this.selectedTags.splice(index, 1)
      } else {
        this.selectedTags.push(tag)
      }

      this.$emit('update:selectedTags', this.selectedTags)
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-tag {
  font-size: 14px;
  width: 100%
}
</style>
