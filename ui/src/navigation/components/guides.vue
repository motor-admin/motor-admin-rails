<template>
  <div class="row">
    <div class="col-12 col-xl-2 order-1 order-xl-0">
      <VButton
        v-for="item in steps"
        :key="item.key"
        class="mb-2 d-block w-100"
        :type="currentItem === item ? 'primary' : 'default'"
        :ghost="currentItem === item"
        @click="changeStep(item.key)"
      >
        {{ item.name }}
      </VButton>
    </div>
    <div class="col-12 col-xl-10">
      <div v-if="currentItem.videoId">
        <div class="video-container">
          <iframe
            :src="`https://www.youtube.com/embed/${currentItem.videoId}?rel=0&autoplay=${autoplay}`"
            frameborder="0"
            allow="fullscreen;"
          />
        </div>
        <div class="mt-2 text-center">
          <VButton
            type="primary"
            size="large"
            class="d-none d-xl-inline"
            @click="nextStep"
          >
            Next
            <Icon type="ios-arrow-forward" />
          </VButton>
        </div>
      </div>
      <div
        v-else
        class="text-center mb-2"
        style="max-width: 530px; margin: auto"
      >
        <SubscribeFrom
          v-if="!isSubscribed"
          class="mb-4"
        />

        <p class="fs-3">
          Have a problem or found a bug?
        </p>
        <VButton
          :to="'https://github.com/motor-admin/motor-admin-rails/issues/new'"
          target="_blank"
          icon="ios-bug"
          class="mt-3"
          size="large"
        >
          Open Issue
        </VButton>

        <p class="fs-3 mt-3">
          Enjoy using Motor Admin?
        </p>
        <VButton
          :to="'https://github.com/motor-admin/motor-admin-rails/stargazers'"
          target="_blank"
          class="mt-3"
          icon="md-star"
          size="large"
        >
          Give a Star
        </VButton>
      </div>
    </div>
  </div>
</template>

<script>
import SubscribeFrom from './subscribe_form'
import { currentUser } from '../scripts/user_store'

export default {
  name: 'Guides',
  components: {
    SubscribeFrom
  },
  data () {
    return {
      currentStep: '',
      autoplay: 0,
      isSubscribed: currentUser.isSubscribed
    }
  },
  computed: {
    currentUser: () => currentUser,
    currentItem () {
      return this.steps.find((step) => step.key === this.currentStep)
    },
    steps () {
      return [
        { name: 'Adjusting resources', videoId: 'ngVoci8Hll4', key: 'adjusting_resources' },
        { name: 'Adding column', videoId: '6T5aNhnilI8', key: 'adding_column' },
        { name: 'Query visualization', videoId: 'HSOc3iKxss4', key: 'query_visualization' },
        { name: 'Creating dashboard', videoId: 'ciBGwqOUlgg', key: 'creating_dashboard' },
        { name: 'Custom form action', videoId: 'ZQeR67dKiMI', key: 'custom_form_action' },
        { name: 'Other', key: 'other' }
      ]
    }
  },
  created () {
    this.currentStep = this.steps[0].key
  },
  methods: {
    changeStep (value) {
      this.currentStep = value

      this.autoplay = 1
    },
    nextStep () {
      const index = this.steps.findIndex((step) => step.key === this.currentStep)

      this.autoplay = 1
      this.currentStep = this.steps[index + 1].key
    }
  }
}
</script>

<style lang="scss" scoped>
.video-container {
  overflow: hidden;
  position: relative;
  width:100%;
}

.video-container::after {
  padding-top: 56.25%;
  display: block;
  content: '';
}

.video-container iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
</style>
