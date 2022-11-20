<template>
  <div>
    <NoteTextarea
      v-model="noteBody"
      :rows="10"
      @keyup.shift.enter.prevent="submit"
      @keydown.shift.enter.prevent
    />
    <VButton
      :loading="isLoading"
      class="mt-2"
      long
      @click="submit"
    >
      {{ i18n.submit }}
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import NoteTextarea from './textarea'

export default {
  name: 'NoteEdit',
  components: {
    NoteTextarea
  },
  props: {
    note: {
      type: Object,
      required: true
    }
  },
  emits: ['success'],
  data () {
    return {
      isLoading: false,
      noteBody: ''
    }
  },
  mounted () {
    this.noteBody = this.note.body
  },
  methods: {
    submit () {
      this.isLoading = true

      api.put(`notes/${this.note.id}`, {
        data: {
          body: this.noteBody
        }
      }).then((result) => {
        this.$emit('success')
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
