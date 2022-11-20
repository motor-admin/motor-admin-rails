import consumer from './consumer'
import mitt from 'mitt'

const notificationsBus = mitt()

function subscribeToNotifications () {
  return consumer.subscriptions.create('Motor::NotificationsChannel', {
    received ([action, data]) {
      notificationsBus.emit(action, data)
    }
  })
}

function subscribeToNotes (room, received) {
  return consumer.subscriptions.create({ channel: 'Motor::NotesChannel', room }, { received })
}

export { subscribeToNotifications, notificationsBus, subscribeToNotes }
