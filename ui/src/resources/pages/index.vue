<template>
  <div class="row mx-2">
    <h1 class="mt-3 mb-2">
      Resources
    </h1>
    <div
      v-for="resource in resources"
      :key="resource.slug"
      class="col-12 col-md-6 col-lg-4 col-xl-3"
    >
      <RouterLink
        class="ivu-card ivu-card-bordered my-2"
        :to="{ name: 'resources', params: { fragments: [resource.slug] }}"
      >
        <div class="ivu-card-body">
          <h3 class="text-muted">
            <Icon type="md-list" />
            {{ resource.display_name }}
          </h3>
        </div>
      </RouterLink>
    </div>
  </div>
</template>

<script>
import { schema } from 'utils/scripts/schema'

export default {
  name: 'ResourcesIndex',
  computed: {
    resources () {
      return schema
    }
  }
}
</script>

<style lang="scss">
</style>
