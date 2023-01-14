import { cablePath } from 'utils/scripts/configs'
import { createConsumer } from '@rails/actioncable'

let consumer

const dummyConsumer = { subscriptions: { create: () => {}, remove: () => {} } }

if (cablePath) {
  consumer = createConsumer(cablePath)
} else {
  consumer = dummyConsumer
}

export default consumer
