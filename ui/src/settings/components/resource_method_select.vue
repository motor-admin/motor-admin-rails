<template>
  <MSelect
    v-model="modelValue"
    filterable
    :options="options"
    :with-deselect="false"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import api from 'api'

export default {
  name: 'ResourceMethodSelect',
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    resourceSlug: {
      type: String,
      required: true
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      options: []
    }
  },
  mounted () {
    this.loadMethods()
  },
  methods: {
    loadMethods (query) {
      return api.get(`resource_methods/${this.resourceSlug}`, {
      }).then((result) => {
        this.options = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
