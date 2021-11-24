<template>
  <VueDraggableNext
    :list="resource.associations"
    handle=".handle"
    @change="onAssociationMove"
  >
    <Association
      v-for="association in resource.associations"
      :key="association.slug"
      :resource-name="resource.name"
      :association="association"
      class="pb-2"
    />
  </VueDraggableNext>
  <Card
    v-if="newAssociation"
  >
    <AssociationForm
      ref="newForm"
      :association="newAssociation"
      :resource-name="resource.name"
      @cancel="newAssociation = null"
      @submit="onAssociationSubmit"
    />
  </Card>
  <div
    v-else
    class="py-2 border-top"
  >
    <VButton
      long
      icon="md-add"
      @click="addAssociation"
    >
      {{ i18n['add_association'] }}
    </VButton>
  </div>
</template>

<script>
import Association from './resource_association'
import AssociationForm from './resource_association_form'
import api from 'api'
import { underscore } from 'utils/scripts/string'

const defaultAssociationAttributes = {
  display_name: '',
  name: '',
  slug: '',
  model_name: '',
  foreign_key: '',
  primary_key: '',
  polymorphic: false,
  options: {},
  icon: 'database',
  virtual: true,
  visible: true
}

export default {
  name: 'ResourceAssociationsList',
  components: {
    Association,
    AssociationForm
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      newAssociation: null
    }
  },
  methods: {
    addAssociation () {
      this.newAssociation = JSON.parse(JSON.stringify(defaultAssociationAttributes))
    },
    onAssociationSubmit (assoc) {
      assoc.name = underscore(assoc.display_name)
      assoc.slug = underscore(assoc.display_name)

      if (assoc.model_name === 'active_storage/attachment') {
        assoc.name += '_attachments'
        assoc.slug += '_attachments'
      }

      this.newAssociation = null

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            associations: [
              assoc
            ]
          }
        }
      }).then((result) => {
        this.resource.associations.push(assoc)
      }).catch((error) => {
        console.error(error)
      })
    },
    onAssociationMove () {
      return api.post('configs', {
        data: {
          key: `resources.${this.resource.name}.associations.order`,
          value: this.resource.associations.map((assoc) => assoc.name)
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
