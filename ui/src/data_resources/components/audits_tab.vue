<template>
  <div
    class="p-3"
  >
    <Spin
      v-if="isLoading"
      fix
    />
    <div
      v-else-if="audits.length === 0"
      class="text-center"
    >
      {{ i18n.nothing_to_show_here_yet }}
    </div>
    <AuditItem
      v-for="audit in audits"
      :key="audit.id"
      :resource-name="resourceName"
      :resource-id="resourceId"
      :audit="audit"
      @revert="onRevert"
    />
  </div>
</template>

<script>
import api from 'api'
import AuditItem from './audit_item'
import { modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'ResourceAuditsTab',
  components: {
    AuditItem
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    resourceId: {
      type: [String, Number],
      required: true
    }
  },
  emits: ['update'],
  data () {
    return {
      isLoading: true,
      audits: []
    }
  },
  mounted () {
    this.loadAudits().then(() => {
      this.isLoading = false
    })
  },
  methods: {
    onRevert (data) {
      this.$emit('update', data)

      this.loadAudits()
    },
    loadAudits () {
      return api.get('audits', {
        params: {
          filter: {
            auditable_type: modelNameMap[this.resourceName].class_name,
            auditable_id: this.resourceId
          },
          sort: '-created_at',
          include: 'user'
        }
      }).then((result) => {
        this.audits = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
