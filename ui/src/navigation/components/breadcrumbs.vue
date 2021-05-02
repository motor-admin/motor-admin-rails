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
      {{ crumb.label }}
    </BreadcrumbItem>
  </Breadcrumb>
</template>

<script>
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
  emits: ['click-menu']
}
</script>
