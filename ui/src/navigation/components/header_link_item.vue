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
              class="me-3 cursor-grab"
            />
            <p
              ref="contenteditable"
              class="fs-5 fw-bold cursor-text"
              contenteditable
              @input="updateName"
              @click.stop
              @blur="onNameFocusLost"
              @keydown.enter.prevent="$refs.contenteditable.blur()"
            >
              {{ displayName }}
            </p>
          </div>
          <div class="d-flex align-items-center">
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <LinkForm
          v-if="isForm"
          :link="link"
          class="py-3"
          :with-remove="true"
          @cancel="toggleForm"
          @remove="onRemove"
          @submit="onSubmit"
        />
      </div>
    </div>
  </div>
</template>

<script>
import LinkForm from './header_link_form'

export default {
  name: 'HeaderLink',
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
      isForm: false,
      displayName: this.link.name
    }
  },
  watch: {
    'link.name' (value) {
      if (value.trim() !== this.displayName.trim() &&
        value.trim() !== this.$refs.contenteditable.innerText.trim()) {
        this.displayName = this.link.name
      }
    }
  },
  methods: {
    toggleForm () {
      this.isForm = !this.isForm
    },
    updateName (event) {
      this.link.name = event.target.innerText
    },
    onSubmit (link) {
      this.isForm = false

      this.$emit('submit', link)
    },
    onRemove (link) {
      this.isForm = false

      this.$emit('remove', link)
    },
    onNameFocusLost () {
      if (!this.link.name || this.link.name.match(/^\s+$/)) {
        this.link.name = this.displayName
        this.displayName = this.displayName + ' '
      } else {
        this.$emit('submit', [this.link, this.link])

        this.displayName = this.link.name
      }
    }
  }
}
</script>
