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
          v-if="$can('destroy', itemModelClass, item)"
          class="text-dark float-end pb-2"
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
    itemModelClass () {
      return `Motor::${titleize(this.itemType)}`
    },
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
        title: this.i18n.selected_item_will_be_removed_are_you_sure,
        closable: true,
        onOk: () => {
          api.delete(this.apiPath).then((result) => {
            this.$Message.info(`${titleize(this.itemType)} ${this.i18n.has_been_removed_succesfully}`)

            this.$emit('remove')
          }).catch((error) => {
            console.error(error)
            this.$Message.error(this.i18n.unable_to_remove_item)
          })
        }
      })
    }
  }
}
</script>

<style lang="scss">
@import 'utils/styles/variables';

.report-item {
  button {
    display: none
  }
}

@media screen and (min-width: $breakpoint-md) {
  .report-item:hover {
    button {
      display: block
    }
  }
}
</style>
