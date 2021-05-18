<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
    >
      <div class="ivu-card-body py-0">
        <div
          class="cursor-pointer d-flex align-items-center justify-content-between py-2"
          :style="{ opacity: !isForm && !action.visible ? 0.5 : 1 }"
          @click="toggleForm"
        >
          <div class="d-flex align-items-center">
            <Icon
              v-if="movable"
              type="ios-menu"
              class="me-3 cursor-grab handle"
            />
            <Checkbox
              :model-value="action.visible"
              @click.stop
              @on-change="toggleVisible"
            />
            <p
              ref="contenteditable"
              class="fs-5 fw-bold"
              :contenteditable="!isCrudAction"
              :class="{ 'cursor-text': !isCrudAction }"
              @input="updateName"
              @click="onTextClick"
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
        <ActionForm
          v-if="isForm"
          :action="action"
          class="py-3"
          :with-remove="!isCrudAction"
          :with-name="!isCrudAction"
          :resource="resource"
          @cancel="toggleForm"
          @remove="removeAction"
          @submit="updateAction"
        />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import ActionForm from './resource_action_form'
import { underscore } from 'utils/scripts/string'

export default {
  name: 'ResourceAction',
  components: {
    ActionForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    },
    movable: {
      type: Boolean,
      required: false,
      default: true
    },
    action: {
      type: Object,
      required: true
    }
  },
  emits: ['reorder'],
  data () {
    return {
      isForm: false,
      displayName: this.action.display_name
    }
  },
  computed: {
    isCrudAction () {
      return ['edit', 'create', 'remove'].includes(this.action.name)
    }
  },
  watch: {
    'action.display_name' (value) {
      if (value.trim() !== this.displayName.trim() &&
        value.trim() !== this.$refs.contenteditable.innerText.trim()) {
        this.displayName = this.action.display_name
      }
    }
  },
  methods: {
    removeAction () {
      this.$Dialog.confirm({
        title: 'Are you sure?',
        closable: true,
        onOk: () => {
          const index = this.resource.actions.findIndex((action) => action.name === this.action.name)

          this.removeRequest()
          this.resource.actions.splice(index, 1)
        }
      })
    },
    removeRequest () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            actions: [
              {
                name: this.action.name,
                _remove: true
              }
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    persistChanges () {
      const dataAction = { ...this.action }

      if (dataAction.name) {
        dataAction._update = dataAction.name
      }

      if (!this.isCrudAction) {
        dataAction.name = underscore(dataAction.display_name)
      }

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            actions: [dataAction]
          }
        }
      }).then((result) => {
        if (this.action.name !== dataAction.name) {
          this.action.name = dataAction.name
          this.$emit('reorder')
        }
      }).catch((error) => {
        console.error(error)
      })
    },
    toggleVisible (value) {
      this.action.visible = value

      this.persistChanges()
    },
    toggleForm () {
      this.isForm = !this.isForm
    },
    updateName (event) {
      this.action.display_name = event.target.innerText
    },
    onTextClick (event) {
      if (!this.isCrudAction) {
        event.stopPropagation()
      }
    },
    updateAction (action) {
      this.isForm = false

      Object.assign(this.action, action)

      this.persistChanges()
    },
    onNameFocusLost () {
      if (this.displayName === this.action.display_name) {
        return
      }

      if (!this.action.display_name || this.action.display_name.match(/^\s+$/)) {
        this.action.display_name = this.displayName
        this.displayName = this.displayName + ' '
      } else {
        this.persistChanges()

        this.displayName = this.action.display_name
      }
    }
  }
}
</script>
