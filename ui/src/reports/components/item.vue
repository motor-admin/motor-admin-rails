<template>
  <RouterLink
    class="report-item ivu-card ivu-card-bordered mb-2"
    :to="{ name: itemType, params: { id: item.id }}"
  >
    <div class="ivu-card-body">
      <p class="fs-4 fw-bold text-dark">
        <Icon :type="iconClass" />
        {{ item.name || item.title }}
        <VButton
          class="text-dark float-right pb-2"
          type="text"
          icon="md-trash"
          @click.prevent="remove"
        />
      </p>
      <div />
    </div>
  </RouterLink>
</template>

<script>
import api from 'api'
import { titleize } from 'utils/scripts/string'

export default {
  name: 'ReportItem',
  props: {
    item: {
      type: Object,
      required: true
    },
    itemType: {
      type: String,
      required: true
    }
  },
  emits: ['remove'],
  computed: {
    iconClass () {
      return {
        query: 'md-list',
        dashboard: 'md-analytics',
        alert: 'md-notifications',
        form: 'md-list-box'
      }[this.itemType]
    },
    apiPath () {
      if (this.itemType === 'query') {
        return `queries/${this.item.id}`
      } else if (this.itemType === 'dashboard') {
        return `dashboards/${this.item.id}`
      } else if (this.itemType === 'alert') {
        return `alerts/${this.item.id}`
      } else if (this.itemType === 'form') {
        return `forms/${this.item.id}`
      } else {
        return ''
      }
    }
  },
  methods: {
    remove () {
      this.$Dialog.confirm({
        title: 'Selected item will be removed. Are you sure?',
        closable: true,
        onOk: () => {
          api.delete(this.apiPath).then((result) => {
            this.$Message.info(`${titleize(this.itemType)} has been removed succesfully`)

            this.$emit('remove')
          }).catch((error) => {
            console.error(error)
            this.$Message.error('Unable to remove item')
          })
        }
      })
    }
  }
}
</script>

<style lang="scss">
.report-item {
  button {
    display: none
  }
}

.report-item:hover {
  button {
    display: block
  }
}
</style>
