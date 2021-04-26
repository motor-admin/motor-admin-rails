<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
    >
      <div class="ivu-card-body py-0">
        <div
          class="cursor-pointer d-flex align-items-center justify-content-between py-2"
          :style="{ opacity: !isForm && scope.access_type === 'hidden' ? 0.5 : 1 }"
          @click="toggleForm"
        >
          <div class="d-flex align-items-center">
            <Icon
              type="ios-menu"
              class="me-3 cursor-grab handle"
            />
            <Checkbox
              :model-value="scope.visible"
              @click.stop
              @on-change="toggleVisible"
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
          <div
            v-if="scope.scope_type === 'filter'"
            class="d-flex align-items-center"
          >
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <ScopeForm
          v-if="isForm"
          :scope="scope"
          :resource="resource"
          class="py-3"
          :with-remove="true"
          @cancel="toggleForm"
          @remove="removeScope"
          @submit="updateScope"
        />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import ScopeForm from './resource_scope_form'

export default {
  name: 'ResourceScope',
  components: {
    ScopeForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    },
    scope: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      isForm: false,
      displayName: this.scope.display_name
    }
  },
  watch: {
    'scope.display_name' (value) {
      if (value.trim() !== this.displayName.trim() &&
        value.trim() !== this.$refs.contenteditable.innerText.trim()) {
        this.displayName = this.scope.display_name
      }
    }
  },
  methods: {
    removeScope () {
      this.$Dialog.confirm({
        title: 'Are you sure?',
        closable: true,
        onOk: () => {
          const index = this.resource.scopes.findIndex((scope) => scope.name === this.scope.name)

          this.resource.scopes.splice(index, 1)

          api.post('resources', {
            data: {
              name: this.resource.name,
              preferences: {
                scopes: [
                  {
                    name: this.scope.name,
                    _remove: true
                  }
                ]
              }
            }
          }).then((result) => {
          }).catch((error) => {
            console.error(error)
          })
        }
      })
    },
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            scopes: [
              this.scope
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    toggleVisible (value) {
      this.scope.visible = value

      this.persistChanges()
    },
    toggleForm () {
      if (this.scope.scope_type === 'filter') {
        this.isForm = !this.isForm
      }
    },
    updateName (event) {
      this.scope.display_name = event.target.innerText
    },
    updateScope (scope) {
      Object.assign(this.scope, scope)

      this.persistChanges()

      this.isForm = false
    },
    onNameFocusLost () {
      if (!this.scope.display_name || this.scope.display_name.match(/^\s+$/)) {
        this.scope.display_name = this.displayName
        this.displayName = this.displayName + ' '
      } else {
        this.persistChanges()

        this.displayName = this.scope.display_name
      }
    }
  }
}
</script>
