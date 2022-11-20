<template>
  <div>
    <Card>
      <div class="d-flex">
        <div
          class="d-flex flex-column align-items-center"
          style="width: 50px"
        >
          <span
            :style="`background: ${tagColors[0]}; border: 1px solid ${tagColors[1]}; color: ${tagColors[1]};`"
            style="border-radius: 100%; height: 42px; width: 42px; padding-top: 10px"
            class="me-2 text-center"
          >
            {{ userabbr }}
          </span>
        </div>
        <div
          class="px-2 richtext"
          style="width: calc(100% - 150px)"
          v-html="sanitizedHtml"
        />
        <div
          style="width: 100px"
          class="d-flex align-items-end justify-content-end"
        >
          <VButton
            v-if="!currentUserReminder"
            icon="md-notifications"
            class="ms-1"
            size="small"
            style="border-radius: 100%"
            @click="createReminder"
          />
          <a
            v-if="currentUserReminder"
            class="ivu-btn ivu-btn-default ivu-btn-small ivu-btn-icon-only ms-1"
            style="border-radius: 100%"
            :href="calendarUrl"
          >
            <i class="ion ion-md-download" />
          </a>
          <VButton
            v-if="currentUserReminder"
            icon="md-notifications-off"
            class="ms-1"
            size="small"
            style="border-radius: 100%"
            @click="removeReminder"
          />
          <VButton
            v-if="$can('edit', 'Motor::Note', note)"
            icon="md-create"
            size="small"
            class="ms-1"
            style="border-radius: 100%"
            @click="edit"
          />
          <VButton
            v-if="$can('remove', 'Motor::Note', note)"
            icon="md-trash"
            size="small"
            class="ms-1"
            style="border-radius: 100%"
            @click="remove"
          />
        </div>
      </div>
    </Card>
    <div class="text-end">
      <small>{{ username }} at {{ formatDate(note.created_at, null, true) }}</small>
    </div>
  </div>
</template>

<script>
import api from 'api'
import NoteEdit from './edit'
import ReminderForm from './reminder_form'
import { colorsForTag } from 'data_cells/scripts/tag_colors'
import { currentUser } from 'navigation/scripts/user_store'
import { formatDate } from 'utils/scripts/date_format'
import { modelClassNameMap } from 'data_resources/scripts/schema'
import DOMPurify from 'dompurify'
import { marked } from 'marked'

export default {
  name: 'Note',
  props: {
    note: {
      type: Object,
      required: true
    }
  },
  emits: ['remove', 'remove-reminder'],
  computed: {
    username () {
      return this.note.author?.email || this.i18n.internal
    },
    sanitizedHtml () {
      return DOMPurify.sanitize(marked(this.note.body.replace(/\n+/g, '\n\n')))
    },
    userabbr () {
      return this.note.author?.email ? this.username[0].toUpperCase() + this.username[1].toUpperCase() : 'N/A'
    },
    tagColors () {
      return colorsForTag(this.username)
    },
    currentUserReminder () {
      if (currentUser.id) {
        return this.note.reminders.find((r) => r.author_id === currentUser.id)
      } else {
        return null
      }
    },
    calendarUrl () {
      const time = new Date(this.currentUserReminder.scheduled_at).toISOString().replace(/[-:]|\.\d{3}/g, '')

      const components = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'BEGIN:VEVENT',
        `DTSTART:${time}`,
        `DTEND:${time}`,
        `SUMMARY:Reminder for ${modelClassNameMap[this.note.record_type]?.display_name} #${this.note.record_id}`,
        `DESCRIPTION:${this.note.body}`,
        'END:VEVENT',
        'END:VCALENDAR'
      ]

      return encodeURI(`data:text/calendar;charset=utf8,${components.join('\n')}`)
    }
  },
  methods: {
    formatDate,
    remove () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: () => {
          api.delete(`notes/${this.note.id}`, {
          }).then(() => {
            this.$emit('remove', this.note)
            this.$Message.info(this.i18n.note_has_been_removed)
          }).catch((error) => {
            console.error(error)
          })
        }
      })
    },
    removeReminder () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: () => {
          this.$emit('remove-reminder', this.currentUserReminder)

          api.delete(`reminders/${this.currentUserReminder.id}`, {
          }).then(() => {
            this.$Message.info(this.i18n.reminder_has_been_removed)
          }).catch((error) => {
            console.error(error)
          })
        }
      })
    },
    createReminder () {
      this.$Modal.open(ReminderForm, {
        note: this.note,
        onSuccess: () => {
          this.$Modal.remove()
        }
      }, {
        title: this.i18n.create_reminder,
        closable: true
      })
    },
    edit () {
      this.$Modal.open(NoteEdit, {
        note: this.note,
        onSuccess: () => {
          this.$Modal.remove()
        }
      }, {
        title: this.i18n.edit_note,
        closable: true
      })
    }
  }
}
</script>
