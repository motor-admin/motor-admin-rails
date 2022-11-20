<template>
  <TextareaAutocomplete
    :model-value="modelValue"
    :item-functions="itemLoadFunctions"
    :rows="rows"
    @update:model-value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import api from 'api'
import TextareaAutocomplete from 'utils/components/textarea_autocomplete'

export default {
  name: 'NoteTextates',
  components: {
    TextareaAutocomplete
  },
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    rows: {
      type: Number,
      required: false,
      default: 4
    }
  },
  emits: ['update:modelValue'],
  computed: {
    itemLoadFunctions () {
      return {
        '#': () => {
          return api.get('note_tags').then((result) => {
            return result.data.data.map((e) => ({ label: '#' + e.name, value: '#' + e.name }))
          })
        },
        '@': () => {
          return api.get('users_for_autocomplete').then((result) => {
            return result.data.data.map((e) => ({ label: '@' + e.split('@')[0], value: e }))
          })
        }
      }
    }
  }
}
</script>
