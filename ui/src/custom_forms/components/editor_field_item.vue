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
              {{ field.display_name }}
            </p>
          </div>
          <div class="d-flex align-items-center">
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <FieldForm
          v-if="isForm"
          :field="JSON.parse(JSON.stringify(field))"
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
import FieldForm from './editor_field_form'

export default {
  name: 'FieldItem',
  components: {
    FieldForm
  },
  props: {
    field: {
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

      this.$emit('remove', this.field)
    },
    onSubmit (updatedField) {
      this.isForm = false

      this.$emit('replace', [this.field, updatedField])
    }
  }
}
</script>
