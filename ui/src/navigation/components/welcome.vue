<template>
  <div
    v-if="step === 'welcome'"
    class="text-center"
  >
    <p class="fs-1 fw-bold mb-3 text-center">
      👋 Welcome to Motor Admin
    </p>
    <p class="fs-4 mb-4">
      Motor Admin allows to create a powerful admin panel with writing less code.
    </p>

    <VButton
      size="large"
      class="fs-4 mb-4"
      type="primary"
      ghost
      @click="$emit('open-guides')"
    >
      Watch Features Overview
    </VButton>
    <br>
    <a
      href="#"
      @click.prevent="step = 'subscribe'"
    >
      Skip
    </a>
  </div>
  <div
    v-if="step === 'subscribe'"
    class="text-center"
  >
    <SubscribeFrom class="mb-3" />
    <a
      href="#"
      @click.prevent="$emit('close')"
    >
      Skip
    </a>
  </div>
</template>

<script>
import SubscribeFrom from './subscribe_form'

export default {
  name: 'WelcomeModal',
  components: {
    SubscribeFrom
  },
  emits: ['close', 'open-guides'],
  data () {
    return {
      step: 'welcome'
    }
  }
}
</script>
