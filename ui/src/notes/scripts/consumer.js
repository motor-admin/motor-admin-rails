import { cabelPath } from 'utils/scripts/configs'
import { createConsumer } from '@rails/actioncable'

let consumer

const dummyConsumer = { subscriptions: { create: () => {}, remove: () => {} } }

if (cabelPath) {
  consumer = createConsumer(cabelPath)
} else {
  consumer = dummyConsumer
}

export default consumer
