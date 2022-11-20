<template>
  <Card
    class="m-3"
    :style="{ opacity: notification.status === 'resolved' ? 0.6 : 1 }"
  >
    <div class="d-flex">
      <div style="width: calc(100% - 100px)">
        <p class="fs-5 fw-bold">
          {{ notification.title }}
        </p>
        <div v-html="sanitizedHtml" />
      </div>
      <div
        style="width: 100px"
        class="d-flex align-items-center"
      >
        <VButton
          :to="{ name: 'resources', params: { fragments: [recordModel.slug, note.record_id] }, query: { tab: 'notes' }}"
          icon="ios-redo"
          class="fw-bold me-2"
          style="border-radius: 100%"
          size="large"
          type="primary"
          ghost
        />
        <VButton
          v-if="notification.status === 'pending'"
          icon="md-checkmark"
          class="fw-bold"
          style="border-radius: 100%"
          size="large"
          type="success"
          ghost
          @click="resolve"
        />
        <VButton
          v-else
          :disabled="true"
          icon="md-checkmark"
          style="border-radius: 100%"
          class="fw-bold"
          size="large"
          type="success"
        />
      </div>
    </div>
  </Card>
</template>

<script>
import api from 'api'
import { modelClassNameMap } from 'data_resources/scripts/schema'
import DOMPurify from 'dompurify'
import { marked } from 'marked'

export default {
  name: 'Notification',
  props: {
    notification: {
      type: Object,
      required: true
    }
  },
  computed: {
    sanitizedHtml () {
      return DOMPurify.sanitize(marked(this.notification.description.replace(/\n+/g, '\n\n')))
    },
    note () {
      if (this.notification.record_type === 'Motor::Reminder') {
        return this.notification.record.record
      } else {
        return this.notification.record
      }
    },
    recordModel () {
      return modelClassNameMap[this.note.record_type]
    }
  },
  methods: {
    resolve () {
      api.put(`notifications/${this.notification.id}`, {
        data: {
          status: 'resolved'
        }
      }).then((result) => {
        this.notification.status = result.data.data.status
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
