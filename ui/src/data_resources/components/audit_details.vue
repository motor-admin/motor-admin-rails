<template>
  <div
    v-for="(change, index) in changes"
    :key="index"
  >
    <b>
      {{ columnDisplayName(change[0]) }}
    </b>
    <div>
      <b>Before:</b>
      {{ change[1][0] }}
    </div>
    <div>
      <b>After:</b>
      {{ change[1][1] }}
    </div>
    <div
      v-if="index !== changes.length - 1"
      class="border-top my-2"
    />
  </div>
</template>

<script>
import { modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'AuditDetails',
  props: {
    changes: {
      type: Array,
      required: false,
      default: () => []
    },
    resourceName: {
      type: String,
      required: true
    }
  },
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    }
  },
  methods: {
    columnDisplayName (columnName) {
      return this.model.columns.find((c) => c.name === columnName)?.display_name || columnName
    }
  }
}
</script>
