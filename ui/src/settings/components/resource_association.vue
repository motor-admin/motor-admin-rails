<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
      :style="{ opacity: association.visible ? 1 : 0.5 }"
    >
      <div class="ivu-card-body d-flex align-items-center justify-content-between py-2">
        <div class="d-flex align-items-center">
          <Icon
            type="ios-menu"
            class="me-3 cursor-grab handle"
          />
          <Checkbox
            v-model="association.visible"
            @change="persistChanges"
          />
          <Contenteditable
            v-model="association.display_name"
            class="fs-5 fw-bold"
            @click.stop
            @change="persistChanges"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'

export default {
  name: 'AssociationItem',
  props: {
    resourceName: {
      type: String,
      required: true
    },
    association: {
      type: Object,
      required: true
    }
  },
  methods: {
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resourceName,
          preferences: {
            associations: [
              this.association
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
