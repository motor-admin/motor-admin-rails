<template>
  <div>
    <Spin
      v-if="isLoading"
      fix
    />
    <div
      ref="notes"
      :style="{ height: minimized ? `calc(var(--vh, 100vh) / 2 - ${isCanCreateNote ? '290px' : '138px'})` : `calc(var(--vh, 100vh) - ${isCanCreateNote ? '310px' : '158px'})` }"
      class="overflow-auto"
    >
      <Note
        v-for="note in notes"
        :key="note.id"
        :note="note"
        class="mx-3 my-2"
        @remove="removeNote"
      />
    </div>

    <div
      v-if="isCanCreateNote"
      class="px-3"
    >
      <NoteTextarea v-model="noteBody" />
      <div class="d-flex justify-content-between">
        <div>
          <small>
            Use <code>@</code> to mention users, <code>#</code> to add tags.
          </small>
        </div>
        <VButton
          :loading="isLoadingNote"
          class="float-right"
          @click="sendNote"
        >
          {{ i18n.submit }}
        </VButton>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import consumer from '../scripts/consumer'
import { subscribeToNotes } from '../scripts/subscriptions'
import { modelNameMap } from 'data_resources/scripts/schema'
import Note from './note'
import NoteTextarea from './textarea'

export default {
  name: 'Notes',
  components: {
    Note,
    NoteTextarea
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    },
    minimized: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data () {
    return {
      isLoading: false,
      isLoadingNote: false,
      noteBody: '',
      notes: []
    }
  },
  computed: {
    isCanCreateNote () {
      return this.$can('create', 'Motor::Note')
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    roomKey () {
      return [this.model.class_name, this.resourceId].join(':')
    },
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
  },
  mounted () {
    this.loadNotes()

    this.subscription ||= subscribeToNotes(this.roomKey, this.processEvent)
  },
  beforeUnmount () {
    consumer.subscriptions.remove(this.subscription)
  },
  methods: {
    scrollToLast (isSmooth = false) {
      const lastNote = this.$refs.notes.children[this.$refs.notes.children.length - 1]

      this.$nextTick(() => {
        if (isSmooth) {
          lastNote?.scrollIntoView({ behavior: 'smooth' })
        } else {
          lastNote?.scrollIntoView()
        }
      })
    },
    processEvent ([action, data]) {
      if (action === 'update') {
        this.addOrReplaceNote(data)
      } else if (action === 'remove') {
        this.removeNote(data)
      }

      if (data.id === this.notes[this.notes.length - 1].id) {
        this.scrollToLast(true)
      }
    },
    removeNote (data) {
      const index = this.notes.findIndex((note) => note.id === data.id)

      if (index !== -1) {
        this.notes.splice(index, 1)
      }
    },
    addOrReplaceNote (data) {
      const index = this.notes.findIndex((note) => note.id === data.id)

      if (index === -1) {
        this.notes.push(data)
      } else {
        this.notes.splice(index, 1, data)
      }
    },
    sendNote () {
      this.isLoadingNote = true

      return api.post('notes', {
        data: {
          body: this.noteBody,
          record_id: this.resourceId,
          record_type: this.model.class_name
        },
        include: 'author,tags,reminders'
      }).then((result) => {
        this.addOrReplaceNote(result.data.data)
        this.noteBody = ''

        this.scrollToLast(true)
      }).finally(() => {
        this.isLoadingNote = false
      })
    },
    loadNotes () {
      this.isLoading = true

      return api.get('notes', {
        params: {
          page: {
            limit: 1000
          },
          filter: {
            record_id: this.resourceId,
            record_type: this.model.class_name
          },
          include: 'author,tags,reminders'
        }
      }).then((result) => {
        this.notes = result.data.data

        this.$nextTick(() => {
          this.scrollToLast()
        })
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
