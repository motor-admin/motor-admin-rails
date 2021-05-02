<template>
  <Breadcrumb>
    <BreadcrumbItem
      v-for="(crumb, index) in crumbs"
      :key="index"
      :class="index < crumbs.length - 2 ? 'd-none d-md-inline' : ''"
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
    }
  }
}
</script>
