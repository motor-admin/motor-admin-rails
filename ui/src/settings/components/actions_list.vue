<template>
  <VueDraggableNext
    :list="resource.actions"
    handle=".handle"
    @change="onActionMove"
  >
    <Action
      v-for="action in resource.actions"
      :key="action.name"
      :resource="resource"
      :action="action"
      class="pb-2"
      @reorder="onActionMove"
    />
  </VueDraggableNext>
  <Card
    v-if="newAction"
  >
    <ActionForm
      ref="newForm"
      :action="newAction"
      :resource="resource"
      :with-name="true"
      @cancel="newAction = null"
      @submit="onActionSubmit"
    />
  </Card>
  <div
    v-else
    class="py-2 border-top"
  >
    <VButton
      long
      icon="md-add"
      @click="addAction"
    >
      {{ i18n['add_action'] }}
    </VButton>
  </div>
</template>

<script>
import Action from './resource_action'
import ActionForm from './resource_action_form'
import api from 'api'
import { underscore } from 'utils/scripts/string'

const defaultActionAttributes = {
  display_name: '',
  name: '',
  action_type: 'form',
  preferences: {},
  visible: true
}

export default {
  name: 'ActionsList',
  components: {
    Action,
    ActionForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      newAction: null
    }
  },
  methods: {
    addAction () {
      this.newAction = { ...defaultActionAttributes }

      this.$nextTick(() => {
        this.$refs.newForm.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
      })
    },
    onActionSubmit (action) {
      action.name = underscore(action.display_name)

      this.resource.actions.push(action)
      this.newAction = null

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            actions: [
              action
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    onActionMove () {
      return api.post('configs', {
        data: {
          key: `resources.${this.resource.name}.actions.order`,
          value: this.resource.actions.map((action) => action.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
