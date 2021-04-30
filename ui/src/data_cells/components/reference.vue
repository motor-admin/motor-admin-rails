<template>
  <VButton
    v-popover="popoverParams"
    :to="{ name: 'resources', params: { fragments: [resourceSlug, referenceId].filter(Boolean) }}"
    type="primary"
    ghost
    shape="circle"
    @click.stop
  >
    <template v-if="isNumberId">
      #{{ resourceId }} <template v-if="!polymorphicName">
        {{ truncate(displayText, 20) }}
      </template>
    </template>
    <template v-else>
      {{ truncate(resourceId.toString(), 20) }}
    </template>
  </VButton>
</template>

<script>
import { modelNameMap } from 'data_resources/scripts/schema'
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
      default: () => ({})
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
    isNumberId () {
      return !!this.resourceId.toString().match(/^\d+$/)
    },
    referenceId () {
      return this.referenceData[this.model.primary_key]
    },
    displayText () {
      if (this.referenceData.first_name && this.referenceData.last_name) {
        return [this.referenceData.first_name, this.referenceData.last_name].join(' ')
      } else {
        return this.referenceData[this.model.display_column]
      }
    },
    popoverParams () {
      return {
        trigger: 'mouseenter',
        render: (h) => {
          return h(require('data_resources/components/info').default, {
            resourceName: this.model.name,
            resourceId: this.referenceId,
            oneColumn: true,
            referencePopover: false
          })
        },
        disabled: !this.showPopover || !this.referenceId,
        placement: 'right',
        bodyStyle: {
          whiteSpace: 'break-spaces',
          overflowY: 'scroll',
          minHeight: '50px',
          maxHeight: '300px',
          maxWidth: '300px'
        }
      }
    },
    model () {
      if (this.polymorphicName) {
        return modelNameMap[underscore(this.polymorphicName)]
      } else {
        return modelNameMap[this.referenceName]
      }
    },
    resourceSlug () {
      return this.model.slug
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
