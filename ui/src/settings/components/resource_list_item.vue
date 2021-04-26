<template>
  <div
    class="ivu-card ivu-card-bordered"
    :style="{ opacity: resource.visible ? 1 : 0.5 }"
  >
    <div class="ivu-card-body d-flex align-items-center justify-content-between">
      <div class="d-flex align-items-center">
        <Icon
          type="ios-menu"
          class="me-3 cursor-grab handle"
        />
        <Checkbox
          v-model="resource.visible"
          @click.stop
          @change="persistChanges"
        />
        <p
          ref="contenteditable"
          class="fs-4 fw-bold cursor-text"
          contenteditable
          @input="updateName"
          @click.stop
          @blur="onNameFocusLost"
          @keydown.enter.prevent="$refs.contenteditable.blur()"
        >
          {{ displayName }}
        </p>
      </div>
      <div class="d-flex align-items-center">
        <Icon type="ios-arrow-forward" />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'

export default {
  name: 'ResourceSettingsItem',
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      displayName: this.resource.display_name
    }
  },
  methods: {
    updateName (event) {
      this.resource.display_name = event.target.innerText
    },
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            display_name: this.resource.display_name,
            visible: this.resource.visible
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    },
    onNameFocusLost () {
      if (!this.resource.display_name || this.resource.display_name.match(/^\s+$/)) {
        this.resource.display_name = this.displayName
        this.displayName = this.displayName + ' '
      } else {
        this.persistChanges()

        this.displayName = this.resource.display_name
      }
    }
  }
}
</script>
