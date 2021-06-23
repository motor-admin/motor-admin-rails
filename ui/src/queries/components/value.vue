<template>
  <div
    class="d-flex align-items-center justify-content-center flex-column bg-white"
  >
    <div
      v-if="change || change === 0"
      :class="isPositiveChange ? 'text-success' : 'text-danger'"
    >
      <Icon :type="isPositiveChange ? 'md-arrow-round-up' : 'md-arrow-round-down'" />
      {{ change }}
    </div>
    <p
      v-if="value || value === 0"
      style="font-size: 60px"
      class="fw-bold"
    >
      {{ value }}
    </p>
    <p v-else-if="!loading">
      {{ i18n['no_data'] }}
    </p>
    <div v-if="label">
      {{ label }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ValueResult',
  props: {
    data: {
      type: Array,
      required: false,
      default: () => ([])
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
    },
    valueFormat: {
      type: Object,
      required: false,
      default: () => ({ style: 'decimal' })
    }
  },
  computed: {
    dataRow () {
      return this.data[0] || []
    },
    isPositiveChange () {
      return !this.change.toString().match(/^-/)
    },
    value () {
      return this.label ? this.dataRow[1] : this.dataRow[0]
    },
    change () {
      return this.label ? this.dataRow[2] : this.dataRow[1]
    },
    label () {
      if (this.dataRow.length >= 3) {
        return typeof this.dataRow[0] === 'string' ? this.dataRow[0] : ''
      } else {
        return ''
      }
    }
  }
}
</script>
