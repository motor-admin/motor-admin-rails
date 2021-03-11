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
        return this.referenceData[this.resourceSchema.display_column]
      }
    },
    popoverParams () {
      return {
        trigger: 'mouseenter',
        render: (h) => {
          return h(require('resources/components/info').default, {
            resourceName: this.resourceSchema.name,
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
    resourceSchema () {
      if (this.polymorphicName) {
        return store.getters.namesMap[underscore(this.polymorphicName)]
      } else {
        return store.getters.namesMap[this.referenceName]
      }
    },
    resourceSlug () {
      return this.resourceSchema.slug
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
