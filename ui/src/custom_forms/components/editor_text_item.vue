<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
    >
      <div class="ivu-card-body py-0">
        <div
          class="cursor-pointer d-flex align-items-center justify-content-between py-2"
          @click="toggleForm"
        >
          <div class="d-flex align-items-center">
            <Icon
              type="ios-menu"
              class="me-3 cursor-grab handle"
            />
            <p
              class="fs-5 fw-bold"
            >
              {{ item.display_name }}
            </p>
          </div>
          <div class="d-flex align-items-center">
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <TextForm
          v-if="isForm"
          :item="JSON.parse(JSON.stringify(item))"
          class="py-3"
          :condition-fields="conditionFields"
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
import TextForm from './editor_text_form'

export default {
  name: 'TextItem',
  components: {
    TextForm
  },
  props: {
    item: {
      type: Object,
      required: true
    },
    conditionFields: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['replace', 'remove'],
  data () {
    return {
      isForm: false
    }
  },
  methods: {
    toggleForm () {
      this.isForm = !this.isForm

      if (this.isForm) {
        this.$nextTick(() => {
          this.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    onRemove () {
      this.isForm = false

      this.$emit('remove', this.item)
    },
    onSubmit (updatedItem) {
      this.isForm = false

      this.$emit('replace', [this.item, updatedItem])
    }
  }
}
</script>
