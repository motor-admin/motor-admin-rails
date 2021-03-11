<template>
  <Breadcrumb>
    <BreadcrumbItem
      v-for="(crumb, index) in crumbs"
      :key="index"
      :to="crumb.to"
      class="h4"
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
