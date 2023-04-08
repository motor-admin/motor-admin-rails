<template>
  <Card
    class="mb-2"
  >
    <div class="d-flex justify-content-between">
      <div class="d-flex">
        <span
          :style="`background: ${tagColors[0]}; border: 1px solid ${tagColors[1]}; color: ${tagColors[1]};`"
          style="border-radius: 100%; height: 42px; min-width: 42px; padding-top: 10px"
          class="me-2 text-center"
        >
          {{ userabbr }}
        </span>
        <div class="me-1">
          <span class="fw-bold">
            {{ audit.user?.email || i18n.internal }}
          </span> {{ i18n[audit.action + 'd'] }}
          <template v-if="audit.action === 'update'">
            <template v-if="auditedColumns.length === 2">
              <b
                v-popover="{ content: formatChange(auditedColumns[0][1]), trigger: 'mouseenter', bodyStyle: { textAlign: 'center'} }"
                class="cursor-pointer"
              >{{ columnDisplayName(auditedColumns[0][0]) }}</b> and <b
                v-popover="{ content: formatChange(auditedColumns[1][1]), trigger: 'mouseenter', bodyStyle: { textAlign: 'center'} }"
                class="cursor-pointer"
              >{{ columnDisplayName(auditedColumns[1][0]) }}</b> fields
            </template>
            <template v-else>
              <b
                v-popover="{ content: formatChange(auditedColumns[0][1]), trigger: 'mouseenter', bodyStyle: { textAlign: 'center'} }"
                class="cursor-pointer"
              >
                {{ columnDisplayName(auditedColumns[0][0]) }}
              </b>
              field
            </template>
            <template v-if="auditedColumns.length > 2">
              and <b
                v-popover="{ content: otherFieldsChangesContent, trigger: 'mouseenter', bodyStyle: { whiteSpace: 'pre-wrap' } }"
                class="cursor-pointer"
              >{{ auditedColumns.length - 1 }}</b> other fields
            </template>
          </template>
          <template v-else>
            the record
          </template>
          <br>
          {{ formatDate(audit.created_at, null, true) }}
        </div>
      </div>
      <div class="flex">
        <VButton
          icon="md-search"
          class="d-block d-lg-inline mb-1 mb-lg-0"
          :class="{ 'me-lg-2': audit.action === 'update' }"
          @click="showDetails"
        >
          {{ i18n.details }}
        </VButton>
        <VButton
          v-if="audit.action === 'update'"
          icon="md-refresh"
          type="warning"
          ghost
          class="d-block d-lg-inline"
          @click="revert"
        >
          {{ i18n.revert }}
        </VButton>
      </div>
    </div>
  </Card>
</template>

<script>
import api from 'api'
import { colorsForTag } from 'data_cells/scripts/tag_colors'
import { formatDate } from 'utils/scripts/date_format'
import { modelNameMap } from 'data_resources/scripts/schema'
import AuditDetails from './audit_details'

export default {
  name: 'AuditItem',
  props: {
    audit: {
      type: Object,
      required: true
    },
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    }
  },
  emits: ['revert'],
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    },
    username () {
      return this.audit.user?.email || this.i18n.internal
    },
    userabbr () {
      return this.audit.user?.email ? this.username[0].toUpperCase() + this.username[1].toUpperCase() : 'N/A'
    },
    tagColors () {
      return colorsForTag(this.username)
    },
    auditedColumns () {
      return Object.entries(this.audit.audited_changes)
    },
    otherFieldsChangesContent () {
      return this.auditedColumns.slice(1).map((values) => [values[0], this.formatChange(values[1])].join(': ')).join('\n')
    },
    revertData () {
      return this.auditedColumns.reduce((acc, [name, data]) => {
        acc[name] = data[0]

        return acc
      }, {})
    }
  },
  methods: {
    formatDate,
    formatChange ([before, after]) {
      return `${before ?? 'null'} ➜ ${after ?? 'null'}`
    },
    showDetails () {
      this.$Dialog.info({
        render: (h) => {
          return h(AuditDetails, { changes: this.auditedColumns, resourceName: this.resourceName }, [])
        }
      })
    },
    revert () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: () => {
          return api.put(`data/${this.model.slug}/${this.resourceId}`, {
            data: this.revertData
          }).then((result) => {
            this.$Message.info(`${this.model.display_name} ${this.i18n.has_been_updated}`)

            this.$emit('revert', result.data.data)
          }).catch((error) => {
            console.error(error)

            this.$Message.error(`${this.i18n.action_has_failed_with_code} ${error.response.status}`)
          })
        }
      })
    },
    columnDisplayName (columnName) {
      return this.model.columns.find((c) => c.name === columnName)?.display_name || columnName
    }
  }
}
</script>
