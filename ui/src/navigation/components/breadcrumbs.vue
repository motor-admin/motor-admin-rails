<template>
  <Breadcrumb>
    <VButton
      v-if="withMenu"
      icon="md-menu"
      size="small"
      type="dashed"
      class="me-2 bg-transparent align-bottom"
      @click="$emit('click-menu')"
    />
    <BreadcrumbItem
      v-for="(crumb, index) in crumbs"
      :key="index"
      :class="index < crumbs.length - (crumbs.length % 2 === 0 ? 2 : 3) ? 'd-none d-md-inline' : ''"
      :to="crumb.to"
      class="fs-4"
    >
      {{ truncate(sanitize(crumb.label), 22) }}
    </BreadcrumbItem>
  </Breadcrumb>
</template>

<script>
import DOMPurify from 'dompurify'
import { truncate } from 'utils/scripts/string'

export default {
  name: 'AppBreadcrumbs',
  props: {
    crumbs: {
      type: Array,
      required: true
    },
    withMenu: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['click-menu'],
  methods: {
    truncate,
    sanitize (label) {
      if (label.includes('<')) {
        return DOMPurify.sanitize(label, { ALLOWED_TAGS: [], KEEP_CONTENT: true }).replace('&nbsp;', '')
      } else {
        return label
      }
    }
  }
}
</script>
