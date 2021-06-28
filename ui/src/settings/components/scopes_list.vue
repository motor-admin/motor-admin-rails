<template>
  <VueDraggableNext
    :list="resource.scopes"
    handle=".handle"
    @change="onScopeMove"
  >
    <ResourceScope
      v-for="scope in resource.scopes"
      :key="scope.name"
      :resource="resource"
      :scope="scope"
      class="pb-2"
      @reorder="onScopeMove"
    />
  </VueDraggableNext>
  <Card
    v-if="newScope"
  >
    <ResourceScopeForm
      ref="newForm"
      :scope="newScope"
      :resource="resource"
      @cancel="newScope = null"
      @submit="onScopeSubmit"
    />
  </Card>
  <div
    v-else
    class="py-2 border-top"
  >
    <VButton
      long
      icon="md-add"
      @click="addScope"
    >
      {{ i18n['add_scope'] }}
    </VButton>
  </div>
</template>

<script>
import ResourceScope from './resource_scope'
import ResourceScopeForm from './resource_scope_form'
import api from 'api'
import { underscore } from 'utils/scripts/string'

const defaultScopeAttributes = {
  display_name: '',
  name: '',
  visible: true,
  scope_type: 'filter',
  preferences: {}
}

export default {
  name: 'ResourceScopesList',
  components: {
    ResourceScope,
    ResourceScopeForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      newScope: null
    }
  },
  methods: {
    addScope () {
      this.newScope = { ...defaultScopeAttributes, virtual: true }

      this.$nextTick(() => {
        this.$refs.newForm.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
      })
    },
    onScopeSubmit (scope) {
      scope.name = underscore(scope.display_name)

      this.resource.scopes.push(scope)
      this.newScope = null

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            scopes: [
              scope
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    onScopeMove () {
      return api.post('configs', {
        data: {
          key: `resources.${this.resource.name}.scopes.order`,
          value: this.resource.scopes.map((scope) => scope.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
