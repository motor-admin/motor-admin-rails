<template>
  <VButton
    v-popover="popoverParams"
    :to="{ name: 'resources', params: { fragments: [resourceSlug, resourceId] }}"
    type="primary"
    ghost
    shape="circle"
    @click.stop
  >
    #{{ resourceId }} <template v-if="!polymorphicName">
      {{ truncate(displayText, 22) }}
    </template>
  </VButton>
</template>

<script>
import store from 'store'
import { truncate, underscore } from 'utils/scripts/string'

const DISPLAY_KEYS = [
  'name',
  'full_name',
  'last_name',
  'first_name',
  'phone',
  'email',
  'domain',
  'phone',
  'title',
  'url'
]

const DISPLAY_KEY_REGEXP = new RegExp(DISPLAY_KEYS.join('|'))

export default {
  name: 'ResourceReference',
  props: {
    resourceId: {
      type: [String, Number],
      required: true
    },
    referenceName: {
      type: String,
      required: true
    },
    referenceData: {
      type: [String, Object],
      required: false,
      default: ''
    },
    polymorphicName: {
      type: String,
      required: false,
      default: ''
    },
    showPopover: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
    displayText () {
      if (this.referenceData.first_name && this.referenceData.last_name) {
        return [this.referenceData.first_name, this.referenceData.last_name].join(' ')
      } else {
        const key = (
          DISPLAY_KEYS.find((key) => this.referenceData[key]) ||
          Object.keys(this.referenceData).find((key) => key.match(DISPLAY_KEY_REGEXP))
        )

        return this.referenceData[key]
      }
    },
    popoverParams () {
      return {
        trigger: 'mouseenter',
        render: (h) => {
          return h(require('resources/components/info').default, {
            resourceName: this.resourceSlug,
            resourceId: this.resourceId,
            oneColumn: true,
            referencePopover: false
          })
        },
        disabled: !this.showPopover,
        placement: 'right',
        bodyStyle: {
          overflowY: 'scroll',
          minHeight: '50px',
          maxHeight: '300px',
          maxWidth: '300px'
        }
      }
    },
    resourceSlug () {
      if (this.polymorphicName) {
        return store.getters.namesMap[underscore(this.polymorphicName)].slug
      } else {
        return store.getters.namesMap[this.referenceName].slug
      }
    }
  },
  methods: { truncate }
}
</script>

<style lang="scss">
.ivu-poptip-popper[x-placement="right"] .ivu-poptip-arrow {
  margin-top: -7px;
  top: 7%;
}
</style>
