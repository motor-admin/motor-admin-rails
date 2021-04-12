<template>
  <RouterLink
    class="query-item ivu-card ivu-card-bordered mb-2"
    :to="{ name: item.type, params: { id: item.id }}"
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
    }
  },
  emits: ['remove'],
  computed: {
    iconClass () {
      return this.item.type === 'query' ? 'md-list' : 'md-analytics'
    },
    apiPath () {
      if (this.item.type === 'query') {
        return `api/queries/${this.item.id}`
      } else if (this.item.type === 'dashboard') {
        return `api/dashboards/${this.item.id}`
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
            this.$Message.success(`${titleize(this.item.type)} has been removed succesfully`)

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
.query-item {
  button {
    display: none
  }
}

.query-item:hover {
  button {
    display: block
  }
}
</style>
