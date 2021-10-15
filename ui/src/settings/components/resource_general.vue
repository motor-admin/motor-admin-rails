<template>
  <VForm
    label-position="top"
    :model="resource"
    :rules="rules"
  >
    <FormItem
      :label="i18n['display_column']"
      prop="display_column"
    >
      <MSelect
        v-model="resource.display_column"
        :with-deselect="false"
        :label-key="'display_name'"
        :value-key="'name'"
        :options="readableColumns"
        @update:modelValue="persistChanges"
      />
    </FormItem>
  </VForm>
</template>

<script>
import api from 'api'

export default {
  name: 'ResourceGeneral',
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  computed: {
    readableColumns () {
      return this.resource.columns.filter((c) => {
        return ['read_only', 'read_write'].includes(c.access_type) && c.reference?.reference_type !== 'has_one'
      })
    },
    rules () {
      return {
        display_column: [{ required: true }]
      }
    }
  },
  methods: {
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            display_column: this.resource.display_column
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>