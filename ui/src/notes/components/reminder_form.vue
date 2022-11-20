<template>
  <div>
    <label>{{ i18n.schedule_at }}:</label>
    <DatePicker
      v-model="scheduledAt"
      class="ms-2"
      type="datetime"
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

export default {
  name: 'ReminderForm',
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
      scheduledAt: new Date()
    }
  },
  mounted () {
    this.noteBody = this.note.body
  },
  methods: {
    submit () {
      this.isLoading = true

      api.post('reminders', {
        data: {
          scheduled_at: this.scheduledAt,
          record_id: this.note.id,
          record_type: 'Motor::Note'
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
