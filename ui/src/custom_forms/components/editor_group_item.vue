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
              {{ group.display_name }}
            </p>
          </div>
          <div class="d-flex align-items-center">
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <LayoutItems
          v-if="!isForm"
          :items="group.items"
          :condition-fields="conditionFields"
          :with-min-height="true"
        />
        <GroupForm
          v-if="isForm"
          :group="JSON.parse(JSON.stringify(group))"
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
import GroupForm from './editor_group_form'
import { defineAsyncComponent } from 'vue'

const LayoutItems = defineAsyncComponent(() => import('./editor_items_list'))

export default {
  name: 'FieldItem',
  components: {
    LayoutItems,
    GroupForm
  },
  props: {
    group: {
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

      this.$emit('remove', this.group)
    },
    onSubmit (updatedGroup) {
      this.isForm = false

      this.$emit('replace', [this.group, updatedGroup])
    }
  }
}
</script>
