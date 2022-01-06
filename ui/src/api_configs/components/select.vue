<template>
  <MSelect
    :model-value="modelValue"
    :size="size"
    :options="configs"
    :label-function="labelFunction"
    value-key="name"
    :allow-create="true"
    :create-function="addOption"
    :placeholder="i18n['url']"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import api from 'api'

export default {
  name: 'ApiConfigSelect',
  props: {
    modelValue: {
      type: [String, Number],
      required: false,
      default: ''
    },
    size: {
      type: String,
      required: false,
      default: 'default'
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      configs: []
    }
  },
  mounted () {
    this.loadConfigs()
  },
  methods: {
    labelFunction (item) {
      if (item.name === 'origin') {
        return 'Origin'
      } else {
        return item.url
      }
    },
    addOption (value) {
      return Promise.resolve({ name: value, url: value })
    },
    loadConfigs () {
      return api.get('api_configs', {
        params: {
          fields: {
            api_config: 'id,name,url'
          }
        }
      }).then((result) => {
        this.configs = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>

 <style lang="scss">
 </style>
