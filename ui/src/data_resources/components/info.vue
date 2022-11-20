<template>
  <div
    :style="{ position: 'relative' }"
    :class="{ 'h-100': isLoading }"
  >
    <Spin
      v-if="isLoading || isReloading"
      fix
    />
    <div
      v-if="!isLoading"
      class="d-flex flex-column h-100"
    >
      <div
        v-if="withStickyTitle"
        ref="observerElement"
        style="height: 7px"
      />
      <div
        ref="title"
        class="d-flex"
        style="z-index: 1"
      >
        <div
          class="position-relative"
          style="min-width: 250px"
          :style="withActions && !notFound ? (widthLessThan('lg') ? 'width: calc(100% - 100px)' : 'width: 50%') : 'width: 100%'"
        >
          <p
            v-if="notFound"
            class="text-center mt-2"
          >
            {{ i18n['not_found'] }}
          </p>
          <p
            v-else-if="model.display_primary_key"
            class="fs-2 fw-bold"
            :style="withStickyTitle ? 'margin: 9px 0' : 'margin-bottom: 9px'"
          >
            {{ title }}
          </p>
          <InfoCell
            v-else
            :resource="resource"
            :column="displayColumn"
            :style="withStickyTitle ? 'margin: 9px 0' : 'margin-bottom: 9px'"
            :resource-name="resourceName"
            :editable="editable && $can('edit', model.class_name, resource)"
            :reference-popover="referencePopover"
            class="fs-2 fw-bold"
            @update="assignResource"
          />
          <div
            v-if="isShowSettings"
            class="settings-mask"
          />
        </div>
        <div
          v-if="withActions && !notFound"
          class="d-flex justify-content-end align-items-center"
          style="z-index: 0"
          :style="widthLessThan('lg') ? 'width: 100px' : 'width: 50%'"
        >
          <SettingsMask
            v-if="isShowSettings"
            :button-only="true"
            :settings-type="'actions'"
            :resource="model"
          />
          <ResourceActions
            v-else
            :resources="[resource]"
            :resource-name="model.name"
            :button-type="'primary'"
            :button-ghost="false"
            :label="i18n['actions']"
            :with-buttons="!widthLessThan('lg')"
            :placement="'bottom-end'"
            @start-action="isReloading = true"
            @finish-action="onFinisAction"
          />
        </div>
      </div>
      <div
        v-if="!notFound"
        class="position-relative"
        :style="{
          maxWidth: oneColumn && !notFound ? '500px' : '',
          overflow: isShowSettings ? 'hidden' : '',
          height: isShowSettings ? Math.min($refs.columnsWrapper.offsetHeight, $parent.$parent.$el.offsetHeight - 110) + 'px' : 'auto'
        }"
      >
        <SettingsMask
          v-if="isShowSettings"
          :resource="model"
          :settings-type="'columns'"
        />
        <div
          ref="columnsWrapper"
          class="row"
        >
          <template
            v-for="column in columns"
            :key="column.name"
          >
            <div
              :class="oneColumn ? 'col-12' : 'col-xxl-3 col-xl-6 col-md-12 col-12'"
              class="mb-3"
            >
              <i
                v-if="column.description"
                v-popover="
                  {
                    content: column.description,
                    trigger: 'mouseenter',
                    placement: 'top-left',
                    bodyStyle: {
                      maxWidth: '350px',
                      overflowY: 'auto',
                      maxHeight: '200px',
                      whiteSpace: 'pre-wrap',
                      lineBreak: 'anywhere'
                    }
                  }
                "
                class="ion ion-md-information-circle me-1 cursor-pointer"
              />
              <b>
                {{ column.display_name }}:
              </b>
              <br>
              <InfoCell
                :resource="resource"
                :column="column"
                :resource-name="resourceName"
                :editable="editable && $can('edit', model.class_name, resource)"
                :reference-popover="referencePopover"
                :reference-size="oneColumn ? 30 : 20"
                @update="assignResource"
              />
            </div>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import singularize from 'inflected/src/singularize'

import InfoCell from './info_cell'
import ResourceActions from './actions'

import { assignBreadcrumbLabel } from 'navigation/scripts/breadcrumb_store'
import { includeParams, fieldsParams } from '../scripts/query_utils'
import { widthLessThan } from 'utils/scripts/dimensions'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'
import throttle from 'view3/src/utils/throttle'

export default {
  name: 'ResourceInfo',
  components: {
    InfoCell,
    ResourceActions,
    SettingsMask
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    },
    withActions: {
      type: Boolean,
      required: false,
      default: false
    },
    withStickyTitle: {
      type: Boolean,
      required: false,
      default: false
    },
    editable: {
      type: Boolean,
      required: false,
      default: false
    },
    oneColumn: {
      type: Boolean,
      required: false,
      default: true
    },
    referencePopover: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['remove', 'update'],
  data () {
    return {
      resource: {},
      notFound: false,
      isLoading: true,
      isReloading: true
    }
  },
  computed: {
    isShowSettings,
    title () {
      const primaryKeyValue = this.resource[this.model.primary_key]
      const isNumber = primaryKeyValue?.toString()?.match(/^\d+$/)

      return `${singularize(this.model.display_name)}${isNumber ? ' #' : ': '}${primaryKeyValue}`
    },
    displayColumn () {
      return this.model.columns.find((column) => column.name === this.model.display_column)
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    columns () {
      return this.model.columns.filter((column) => {
        return column.name !== 'id' &&
          (this.model.display_primary_key || column.name !== this.displayColumn.name) &&
          ['read_only', 'read_write'].includes(column.access_type)
      })
    },
    includeParams () {
      return includeParams(this.model)
    },
    fieldsParams () {
      return fieldsParams(this.model)
    },
    queryParams () {
      const params = {
        fields: this.fieldsParams
      }

      if (this.includeParams) {
        params.include = this.includeParams
      }

      return params
    }
  },
  watch: {
    columns: {
      deep: true,
      handler: throttle(async function () {
        this.loadData()
      }, 3000)
    },
    'model.display_column' () {
      this.assignBreadcrumbLabel()
    },
    'model.display_primary_key' () {
      this.assignBreadcrumbLabel()
    }
  },
  beforeUnmount () {
    this.titleObserver?.disconnect()
  },
  mounted () {
    this.loadData().then(() => {
      if (this.withStickyTitle) {
        this.initializeTitleObserver()
      }
    })
  },
  methods: {
    widthLessThan,
    initializeTitleObserver () {
      this.titleObserver = new IntersectionObserver(
        ([e]) => this.$refs.title.classList.toggle('pinned-resource-title', e.intersectionRatio < 1),
        { threshold: 1.0 }
      )

      if (this.$refs.observerElement) {
        this.titleObserver.observe(this.$refs.observerElement)
      }
    },
    onFinisAction (action) {
      if (action === 'remove') {
        this.$emit('remove', this.resource)
      } else {
        this.loadData()
      }
    },
    assignResource (data) {
      this.resource = data

      this.assignBreadcrumbLabel()

      this.$emit('update', data)
    },
    assignBreadcrumbLabel () {
      const labelParts = this.model.display_primary_key ? [`${this.resourceId.toString().match(/^\d+$/) ? '#' : ''}${this.resourceId}`] : []

      if (this.model.display_column && this.resource[this.model.display_column] && this.resourceId.toString() !== this.resource[this.model.display_column].toString()) {
        labelParts.push(`${this.resource[this.model.display_column]}`)
      }

      assignBreadcrumbLabel(this.resourceName, this.resourceId, labelParts.join(' '))
    },
    loadData () {
      this.isReloading = true

      return api.get(`data/${this.model.slug}/${this.resourceId}`, {
        params: this.queryParams
      }).then((result) => {
        this.assignResource(result.data.data)
      }).catch((error) => {
        if (error.response?.status === 404) {
          this.notFound = true
        } else {
          console.error(error)

          if (error.response?.status === 403) {
            this.notFound = true
          }

          if (error.response?.data?.errors) {
            this.$Message.error(error.response.data.errors.join('\n'))
          } else {
            this.$Message.error(error.message)
          }
        }
      }).finally(() => {
        this.isLoading = false
        this.isReloading = false
      })
    }
  }
}
</script>

<style>
@import 'src/utils/styles/variables';

.pinned-resource-title {
  position: sticky;
  top: 0;
  margin: 0 -16px;
  padding: 0 16px;
  background: #fff;
  z-index: 1;
  border-bottom: 1px solid $border-color-base;
}
</style>
