<template>
  <VButton
    v-popover="popoverParams"
    :to="referenceId || alwaysRefer ? { name: 'resources', params: { fragments: [resourceSlug, referenceId || resourceId].filter(Boolean) }} : null"
    type="primary"
    ghost
    shape="circle"
    @click.stop
  >
    <template v-if="isNumberId">
      <template v-if="alwaysRefer || model.display_primary_key">
        #{{ resourceId }}
      </template> <template v-if="resourceId !== displayText">
        {{ truncate(displayText, maxLength) }}
      </template>
    </template>
    <template v-else>
      {{ truncate(resourceId.toString(), maxLength) }}
    </template>
  </VButton>
</template>

<script>
import { modelNameMap } from 'data_resources/scripts/schema'
import { truncate } from 'utils/scripts/string'

export default {
  name: 'ResourceReference',
  props: {
    resourceId: {
      type: [String, Number],
      required: true
    },
    referenceName: {
      type: String,
      required: false,
      default: ''
    },
    referenceData: {
      type: [String, Object],
      required: false,
      default: () => ({})
    },
    polymorphicModel: {
      type: Object,
      required: false,
      default: null
    },
    maxLength: {
      type: Number,
      required: false,
      default: 20
    },
    alwaysRefer: {
      type: Boolean,
      required: false,
      default: false
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
    isCanRead () {
      return this.$can('read', this.model.class_name, this.referenceData)
    },
    displayText () {
      if (this.referenceData.first_name && this.referenceData.last_name) {
        return [this.referenceData.first_name, this.referenceData.last_name].join(' ')
      } else {
        return this.referenceData[this.model.display_column]
      }
    },
    popoverParams () {
      const tab = this.model.tabs.find((t) => t.name === 'details')

      return {
        trigger: 'mouseenter',
        render: (h) => {
          if (tab?.tab_type === 'query') {
            return h(require('data_resources/components/query_tab').default, {
              tab: tab,
              style: 'min-width: 250px',
              class: 'richtext-no-padding',
              variables: {
                id: this.referenceId,
                [`${this.model.name}_id`]: this.referenceId,
                ...this.referenceData
              }
            })
          } else {
            return h(require('data_resources/components/info').default, {
              resourceName: this.model.name,
              resourceId: this.referenceId,
              oneColumn: true,
              referencePopover: false
            })
          }
        },
        disabled: !this.showPopover || !this.referenceId || !this.isCanRead,
        placement: 'right',
        bodyStyle: {
          whiteSpace: tab?.tab_type === 'query' ? '' : 'break-spaces',
          overflowY: 'auto',
          minHeight: '50px',
          maxHeight: '300px',
          maxWidth: '300px'
        }
      }
    },
    model () {
      if (this.polymorphicModel) {
        return this.polymorphicModel
      } else {
        return modelNameMap[this.referenceName]
      }
    },
    resourceSlug () {
      return this.model.slug
    }
  },
  methods: {
    truncate,
    copyToClipboard () {
      return navigator.clipboard.writeText(this.referenceId)
    }
  }
}
</script>

<style lang="scss">
.ivu-poptip-popper[x-placement="right"] .ivu-poptip-arrow {
  margin-top: -7px;
  top: 7%;
}
</style>

<style lang="scss" scoped>
.ivu-btn {
  user-select: initial
}
</style>
