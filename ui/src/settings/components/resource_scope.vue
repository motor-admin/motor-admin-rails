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
            <Contenteditable
              v-model="scope.display_name"
              class="fs-5 fw-bold cursor-text"
              @click.stop
              @change="persistChanges"
            />
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
import { underscore } from 'utils/scripts/string'

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
  emits: ['reorder'],
  data () {
    return {
      isForm: false
    }
  },
  methods: {
    removeScope () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
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
      const dataScope = { ...this.scope }

      if (dataScope.name) {
        dataScope._update = dataScope.name
      }

      if (dataScope.scope_type === 'filter') {
        dataScope.name = underscore(dataScope.display_name)
      }

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            scopes: [dataScope]
          }
        }
      }).then((result) => {
        if (this.scope.name !== dataScope.name) {
          this.scope.name = dataScope.name
          this.$emit('reorder')
        }
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

        this.$nextTick(() => {
          this.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    updateScope (scope) {
      Object.assign(this.scope, scope)

      this.persistChanges()

      this.isForm = false
    }
  }
}
</script>
