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
        ref="observerElement"
        style="height: 7px"
      />
      <div
        ref="title"
        class="d-flex"
      >
        <div
          class="position-relative"
          style="min-width: 250px"
          :style="withActions && !notFound ? 'width: calc(100% - 100px)' : 'width: 100%'"
        >
          <p
            v-if="notFound"
            class="text-center mt-2"
          >
            {{ i18n['not_found'] }}
          </p>
          <h2
            v-else
            style="margin: 9px 0"
          >
            {{ title }}
          </h2>
          <div
            v-if="isShowSettings"
            class="settings-mask"
          />
        </div>
        <div
          v-if="withActions && !notFound"
          class="d-flex justify-content-end align-items-center"
          style="width: 100px"
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
            @start-action="isReloading = true"
            @finish-action="onFinisAction"
          />
        </div>
      </div>
      <div
        class="row position-relative"
        :style="{
          maxWidth: oneColumn && !notFound ? '500px' : '',
          overflow: isShowSettings ? 'hidden' : ''
        }"
      >
        <SettingsMask
          v-if="isShowSettings"
          :resource="model"
          :settings-type="'columns'"
        />
        <template
          v-for="column in columns"
          :key="column.name"
        >
          <div
            :class="oneColumn ? 'col-12' : 'col-xxl-3 col-xl-6 col-md-12 col-12'"
            class="mb-3"
          >
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
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import singularize from 'inflected/src/singularize'

import InfoCell from './info_cell'
import ResourceActions from './actions'

import { assignBreadcrumbLabel } from 'navigation/scripts/breadcrumb_store'
import { includeParams, fieldsParams } from '../scripts/query_utils'

import { isShowSettings } from 'settings/scripts/toggle'
import SettingsMask from 'settings/components/mask'

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
  emits: ['remove'],
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
      return `${singularize(this.model.display_name)} #${this.resource[this.model.primary_key]}`
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    columns () {
      return this.model.columns.filter((column) => column.name !== 'id' && ['read_only', 'read_write'].includes(column.access_type))
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
      handler (newValue, oldValue) {
        if (newValue.length > oldValue.length) {
          this.loadData()
        }
      }
    }
  },
  beforeUnmount () {
    this.titleObserver?.disconnect()
  },
  mounted () {
    this.loadData().then(() => {
      this.titleObserver = new IntersectionObserver(
        ([e]) => this.$refs.title.classList.toggle('pinned-resource-title', e.intersectionRatio < 1),
        { threshold: 1.0 }
      )

      this.titleObserver.observe(this.$refs.observerElement)
    })
  },
  methods: {
    onFinisAction (action) {
      if (action === 'remove') {
        this.$emit('remove', this.resource)
      } else {
        this.loadData()
      }
    },
    assignResource (data) {
      this.resource = data

      if (this.model.display_column) {
        assignBreadcrumbLabel(
          this.resourceName,
          this.resourceId,
          `#${this.resourceId} ${this.resource[this.model.display_column]}`
        )
      }
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

          this.$Message.error(error.message)
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
