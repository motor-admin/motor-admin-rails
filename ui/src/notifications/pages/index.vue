<template>
  <div
    class="position-relative overflow-auto"
    style="height: calc(var(--vh, 100vh) - 60px)"
  >
    <div
      class="m-auto"
      style="width: 800px"
    >
      <Spin
        v-if="isLoading"
        fix
      />

      <div
        v-if="!isLoading && !notifications.length"
        class="text-center mt-4"
      >
        {{ i18n.nothing_to_show_here_yet }}
      </div>

      <Notification
        v-for="notification in notifications"
        :key="notification.id"
        :notification="notification"
      />
    </div>
  </div>
</template>

<script>
import api from 'api'
import Notification from '../components/notification'
import { notificationsBus } from 'notes/scripts/subscriptions'

export default {
  name: 'NotificationsIndex',
  components: {
    Notification
  },
  data () {
    return {
      notifications: [],
      isLoading: false
    }
  },
  computed: {
  },
  mounted () {
    this.loadNotifications()

    notificationsBus.on('notify', this.loadNotifications)
  },
  beforeUnmount () {
    notificationsBus.off('notify', { handler: this.loadNotifications })
  },
  methods: {
    loadNotifications () {
      this.isLoading = true

      api.get('notifications', {
        params: {
          page: {
            limit: 1000
          },
          filter: {
            status: 'pending'
          },
          include: 'record,record.author,record.record'
        }
      }).then((result) => {
        this.notifications = result.data.data
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
