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
    <FormItem
      :label="i18n['display_id']"
      class="mb-1"
      prop="display_column"
    >
      <Checkbox
        v-model="resource.display_primary_key"
        @update:modelValue="persistChanges"
      />
    </FormItem>
    <FormItem
      :label="i18n['searchable_columns']"
      class="mb-1"
      prop="searchable_columns"
    >
      <MSelect
        v-model="resource.searchable_columns"
        multiple
        :options="searchableColumnOptions"
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
    searchableColumnOptions () {
      return this.resource.columns.reduce((acc, column) => {
        if (['read_only', 'read_write'].includes(column.access_type) && !column.virtual) {
          acc.push({ label: column.display_name, value: column.name })
        }

        return acc
      }, [])
    },
    rules () {
      return {
      }
    }
  },
  methods: {
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            display_column: this.resource.display_column,
            display_primary_key: this.resource.display_primary_key,
            searchable_columns: this.resource.searchable_columns
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
