<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
    >
      <div class="ivu-card-body py-0">
        <div
          class="cursor-pointer d-flex align-items-center justify-content-between py-2"
          :style="{ opacity: !isForm && link.access_type === 'hidden' ? 0.5 : 1 }"
          @click="toggleForm"
        >
          <div class="d-flex align-items-center">
            <Icon
              type="ios-menu"
              class="me-3 cursor-grab handle"
            />
            <Contenteditable
              v-model="link.name"
              class="fs-5 fw-bold"
              @click.stop
              @change="$emit('submit', [link, link])"
            />
          </div>
          <div class="d-flex align-items-center">
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <LinkForm
          v-if="isForm"
          :link="link"
          class="py-3"
          :with-remove="!['forms', 'reports'].includes(link.link_type)"
          @cancel="toggleForm"
          @remove="onRemove"
          @submit="onSubmit"
        />
      </div>
    </div>
  </div>
</template>

<script>
import LinkForm from './link_form'

export default {
  name: 'LinkItem',
  components: {
    LinkForm
  },
  props: {
    link: {
      type: Object,
      required: true
    }
  },
  emits: ['remove', 'submit'],
  data () {
    return {
      isForm: false
    }
  },
  methods: {
    toggleForm () {
      this.isForm = !this.isForm
    },
    onSubmit (link) {
      this.isForm = false

      this.$emit('submit', link)
    },
    onRemove (link) {
      this.isForm = false

      this.$emit('remove', link)
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

:deep(.contenteditable-edit-button) {
  display: none
}

@media screen and (min-width: $breakpoint-md) {
  :deep(.ivu-card:hover) {
    .contenteditable-edit-button {
      display: block
    }
  }
}
</style>
