<template>
  <MSelect
    :model-value="modelValue"
    filterable
    multiple
    :options="conversations"
    value-key="id"
    :label-function="buildLabel"
    :placeholder="i18n['select_conversations']"
    :size="'large'"
    @update:selected-options="onSelectedItemsUpdate"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import api from 'api'

let conversationsRequest = null

export default {
  name: 'SlackConversationsSelect',
  props: {
    modelValue: {
      type: Array,
      require: false,
      default: () => []
    }
  },
  emits: ['update:modelValue', 'update:userEmails'],
  data () {
    return {
      conversations: []
    }
  },
  mounted () {
    this.loadConversations()
  },
  methods: {
    buildLabel (item) {
      if (item.is_channel) {
        return `#${item.name}`
      } else {
        return `@${item.name}`
      }
    },
    onSelectedItemsUpdate (items) {
      const data = items.map((e) => {
        if (e.profile?.email) {
          return { id: e.id, email: e.profile.email }
        } else {
          return null
        }
      }).filter(Boolean)

      this.$emit('update:userEmails', data)
    },
    loadConversations () {
      conversationsRequest ||= api.get('slack_conversations')

      return conversationsRequest.then((result) => {
        this.conversations = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
