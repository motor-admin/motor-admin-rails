<template>
  <div :class="{ 'settings-mask': !buttonOnly }">
    <VButton
      ghost
      class="bg-white"
      icon="md-create"
      type="warning"
      @click="openSettings"
    >
      {{ titleize(settingsType || i18n['resources']) }}
    </VButton>
  </div>
</template>

<script>
import { openSettingsDrawer } from 'settings/scripts/drawer'
import { titleize } from 'utils/scripts/string'
import { toggleSettings } from 'settings/scripts/toggle'

export default {
  name: 'SettingsMask',
  props: {
    resource: {
      type: Object,
      required: false,
      default: null
    },
    preferences: {
      type: Object,
      required: false,
      default: null
    },
    settingsType: {
      type: String,
      required: false,
      default: null
    },
    buttonOnly: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
  },
  methods: {
    titleize,
    openSettings () {
      if (this.preferences) {
        toggleSettings()

        this.$router.push({
          name: this.settingsType,
          params: {
            id: this.preferences[`${this.settingsType}_id`]
          }
        })
      } else {
        openSettingsDrawer({
          selectedResource: this.resource,
          settingsType: this.settingsType
        })
      }
    }
  }
}
</script>

<style lang="scss">
.settings-mask {
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  top: 0;
  height: 100%;
  width: 100%;
  background: rgba(255,255,255, 0.5);
  z-index: 999;
}
</style>
