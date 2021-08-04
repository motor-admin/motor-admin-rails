<template>
  <div
    v-if="isUnsavedChanges && !isUnsavedResolved"
    class="d-flex align-items-center justify-content-center flex-column"
  >
    <div>
      {{ i18n.there_are_unsaved_changes_from.replace('%{timestamp}', formatDate(storageTimestamp, null, true)) }}
    </div>
    <div>
      <VButton
        type="text"
        icon="md-close"
        class="bg-transparent"
        @click="clearStorage"
      >
        {{ i18n.clear }}
      </VButton>
      <VButton
        type="text"
        icon="md-refresh"
        class="bg-transparent"
        @click="restoreFromStorage"
      >
        {{ i18n.restore }}
      </VButton>
    </div>
  </div>
</template>

<script>
import { formatDate } from 'utils/scripts/date_format'
import throttle from 'view3/src/utils/throttle'

export default {
  name: 'UnsavedChanges',
  props: {
    modelValue: {
      type: Object,
      required: true
    },
    storageKey: {
      type: String,
      required: true
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      isUnsavedResolved: false,
      defaultValue: JSON.parse(JSON.stringify(this.modelValue))
    }
  },
  computed: {
    isUnsavedChanges () {
      return !!this.storageString
    },
    isValueChanged () {
      return JSON.stringify(this.defaultValue) !== JSON.stringify(this.modelValue)
    },
    storageString () {
      return localStorage.getItem(this.storageKey)
    },
    storageObject () {
      return JSON.parse(this.storageString)
    },
    storageValue () {
      return this.storageObject.value
    },
    storageTimestamp () {
      return this.storageObject.timestamp
    }
  },
  watch: {
    modelValue: {
      deep: true,
      handler: throttle(function () {
        this.handleModelValueChange()
      }, 2 * 1000)
    }
  },
  methods: {
    formatDate,
    handleModelValueChange () {
      if (this.isValueChanged) {
        this.saveInLocalStorage()
      } else {
        this.clearStorage()
      }
    },
    clearStorage () {
      localStorage.removeItem(this.storageKey)

      this.isUnsavedResolved = true
    },
    resetWithDefaultValue (value) {
      this.defaultValue = JSON.parse(JSON.stringify(value))
      this.clearStorage()
    },
    restoreFromStorage () {
      this.$emit('update:modelValue', this.storageValue)

      this.isUnsavedResolved = true
    },
    saveInLocalStorage () {
      localStorage.setItem(
        this.storageKey,
        JSON.stringify({
          timestamp: new Date(),
          value: this.modelValue
        })
      )
    }
  }
}
</script>
