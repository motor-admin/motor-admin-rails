<template>
  <VForm
    label-position="top"
    :model="resource"
    :rules="rules"
  >
    <FormItem
      :label="i18n['display_as']"
      prop="preferences.display_as"
    >
      <MSelect
        v-model="resource.preferences.display_as"
        :with-deselect="false"
        :options="displayOptions"
        @update:model-value="[maybeSetKanbanColumn, persistChanges]"
      />
    </FormItem>
    <FormItem
      v-if="resource.preferences.display_as === 'kanban'"
      :label="i18n['kanban_columns']"
      prop="preferences.kanban_column"
    >
      <MSelect
        v-model="resource.preferences.kanban_column"
        :with-deselect="false"
        :label-key="'display_name'"
        :value-key="'name'"
        :options="kanbanColumns"
        @update:model-value="persistChanges"
      />
      <MSelect
        v-if="kanbanColumn"
        v-model="resource.preferences.kanban_columns"
        :with-deselect="false"
        class="mt-2"
        multiple
        :options="kanbanStatusValueOptions"
        @update:model-value="persistChanges"
      />
    </FormItem>
    <FormItem
      v-if="resource.preferences.display_as === 'kanban'"
      :label="i18n['kanban_card_columns']"
      prop="preferences.kanban_card_columns"
    >
      <MSelect
        v-model="resource.preferences.kanban_card_columns"
        :with-deselect="false"
        :label-key="'display_name'"
        :value-key="'name'"
        multiple
        :options="kanbanCardColumns"
        @update:model-value="persistChanges"
      />
    </FormItem>
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
        @update:model-value="persistChanges"
      />
    </FormItem>
    <FormItem
      :label="i18n['display_id']"
      class="mb-1"
      prop="display_column"
    >
      <Checkbox
        v-model="resource.display_primary_key"
        @update:model-value="persistChanges"
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
        @update:model-value="persistChanges"
      />
    </FormItem>
  </VForm>
</template>

<script>
import api from 'api'
import { titleize } from 'utils/scripts/string'

export default {
  name: 'ResourceGeneral',
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  computed: {
    displayOptions () {
      return [
        { label: 'Table', value: 'table' },
        { label: 'Kanban', value: 'kanban' }
      ]
    },
    kanbanColumns () {
      return this.readableColumns.filter((c) => c.column_type === 'tag')
    },
    kanbanCardColumns () {
      return this.resource.columns.filter((c) => {
        return ['read_only', 'read_write'].includes(c.access_type)
      })
    },
    kanbanColumn () {
      return this.kanbanColumns.find((c) => c.name === this.resource.preferences.kanban_column)
    },
    kanbanStatusValueOptions () {
      if (Array.isArray(this.kanbanColumn.format.select_options)) {
        return (this.kanbanColumn.format.select_options || []).map((e) => {
          return {
            value: e,
            label: titleize(e)
          }
        })
      } else {
        return Object.entries(this.kanbanColumn.format.select_options || {}).map(([k, v]) => {
          return {
            value: k,
            label: v
          }
        })
      }
    },
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
    maybeSetKanbanColumn (value) {
      if (value === 'kanban') {
        this.resource.preferences.kanban_column ||= this.kanbanColumns[0]?.name
        this.resource.preferences.kanban_columns = this.kanbanColumn.preferences?.select_options || []
      }
    },
    persistChanges () {
      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            display_column: this.resource.display_column,
            display_primary_key: this.resource.display_primary_key,
            searchable_columns: this.resource.searchable_columns,
            preferences: this.resource.preferences
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
