<template>
  <div
    class="ivu-card ivu-card-bordered"
    :style="{ opacity: association.visible ? 1 : 0.5 }"
  >
    <div class="ivu-card-body d-flex align-items-center justify-content-between py-2">
      <div class="d-flex align-items-center">
        <Icon
          type="ios-menu"
          class="me-3 cursor-grab"
        />
        <Checkbox
          v-model="association.visible"
          @click.stop
          @change="persistChanges"
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
  data () {
    return {
      displayName: this.association.display_name
    }
  },
  methods: {
    updateName (event) {
      this.association.display_name = event.target.innerText
    },
    persistChanges () {
      return api.post('api/resource_configs', {
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
        console.log(error)
      })
    },
    onNameFocusLost () {
      if (!this.association.display_name || this.association.display_name.match(/^\s+$/)) {
        this.association.display_name = this.displayName
        this.displayName = this.displayName + ' '
      } else {
        this.persistChanges()

        this.displayName = this.association.display_name
      }
    }
  }
}
</script>
