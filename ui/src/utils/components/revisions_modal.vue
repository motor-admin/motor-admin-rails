<template>
  <div>
    <Spin
      v-if="isLoading"
      fix
    />
    <Card
      v-for="audit in audits"
      :key="audit.id"
      class="mb-2"
    >
      <div class="d-flex justify-content-between align-items-center">
        <p class="fs-4 fw-bold">
          {{ formatDate(audit.created_at, null, true) }}
        </p>
        <VButton
          type="warning"
          @click="$emit('revert', audit.revision)"
        >
          {{ i18n['revert'] }}
        </VButton>
      </div>
    </Card>
  </div>
</template>

<script>
import api from 'api'
import { formatDate } from 'utils/scripts/date_format'

export default {
  name: 'RevisionsModal',
  props: {
    auditableName: {
      type: String,
      required: true
    },
    auditableId: {
      type: [String, Number],
      required: true
    }
  },
  emits: ['revert'],
  data () {
    return {
      isLoading: false,
      audits: []
    }
  },
  computed: {
    auditableClasses () {
      return {
        query: 'Motor::Query',
        dashboard: 'Motor::Dashboard',
        alert: 'Motor::Alert',
        form: 'Motor::Form'
      }
    }
  },
  mounted () {
    this.loadAudits().then(() => {
      this.isLoading = false
    })
  },
  methods: {
    formatDate,
    loadAudits () {
      return api.get('audits', {
        params: {
          filter: {
            auditable_type: this.auditableClasses[this.auditableName],
            auditable_id: this.auditableId
          },
          sort: '-created_at',
          include: 'revision'
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
