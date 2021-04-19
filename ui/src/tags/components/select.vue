<template>
  <VSelect
    v-model="dataValue"
    filterable
    allow-create
    multiple
    placeholder="Set tags"
    :loading="isLoading"
    :size="size"
  >
    <VOption
      v-for="tag in tags"
      :key="tag.id"
      :value="tag.name"
    >
      {{ tag.name }}
    </VOption>
  </VSelect>
</template>

<script>
import api from 'api'

export default {
  name: 'TagsSelect',
  props: {
    size: {
      type: String,
      required: false,
      default: 'large'
    },
    modelValue: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      dataValue: [],
      tags: [],
      isLoading: false
    }
  },
  watch: {
    modelValue (value) {
      this.dataValue = value
    },
    dataValue (value) {
      this.$emit('update:modelValue', value)
    }
  },
  mounted () {
    this.dataValue = this.modelValue

    this.loadTags()
  },
  methods: {
    loadTags () {
      this.isLoading = true

      api.get('tags').then((result) => {
        this.tags = result.data.data
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>

<style lang="scss">
</style>
