<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataScope"
    >
      <FormItem
        :label="i18n['name']"
        prop="display_name"
      >
        <VInput v-model="dataScope.display_name" />
      </FormItem>
      <FormItem
        :label="i18n['order_by']"
        prop="preferences.sort"
      >
        <div class="d-flex">
          <MSelect
            :model-value="dataScope.preferences.sort?.key"
            :options="sortColumns"
            label-key="display_name"
            value-key="name"
            class="me-1"
            @update:model-value="setSortKey"
          />
          <MSelect
            :model-value="dataScope.preferences.sort?.order"
            :options="sortDirectionOptions"
            :with-deselect="false"
            class="ms-1"
            @update:model-value="dataScope.preferences.sort ? dataScope.preferences.sort.order = $event : ''"
          />
        </div>
      </FormItem>
      <FormItem
        :label="i18n['filters']"
        prop="preferences.filter"
      >
        <Filters
          v-model:filters="dataScope.preferences.filter"
          :model="resource"
        />
      </FormItem>
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove')"
        >
          {{ i18n['remove'] }}
        </VButton>
        <VButton @click="$emit('cancel')">
          {{ i18n['cancel'] }}
        </VButton>
      </div>
      <VButton
        type="primary"
        :loading="isLoading"
        @click="submit"
      >
        {{ i18n['save'] }}
      </VButton>
    </div>
  </div>
</template>

<script>
import Filters from 'data_resources/components/filters'
import { fieldRequiredMessage } from 'utils/scripts/i18n'

export default {
  name: 'ResourceScopeForm',
  components: {
    Filters
  },
  props: {
    scope: {
      type: Object,
      required: true
    },
    resource: {
      type: Object,
      required: true
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['cancel', 'submit', 'remove'],
  data () {
    return {
      isLoading: false,
      dataScope: {}
    }
  },
  computed: {
    sortDirectionOptions () {
      return [
        { label: this.i18n.ascending, value: 'asc' },
        { label: this.i18n.descending, value: 'desc' }
      ]
    },
    sortColumns () {
      return this.resource.columns.filter((c) => {
        return ['read_only', 'read_write'].includes(c.access_type) && c.reference?.reference_type !== 'has_one'
      })
    },
    rules () {
      const rules = {
        display_name: [{
          required: true,
          message: fieldRequiredMessage('name')
        }]
      }

      return rules
    }
  },
  created () {
    this.dataScope = { ...this.scope }
  },
  methods: {
    setSortKey (value) {
      if (value) {
        this.dataScope.preferences.sort ||= {}
        this.dataScope.preferences.sort.key = value
        this.dataScope.preferences.sort.order ||= 'asc'
      } else {
        delete this.dataScope.preferences.sort
      }
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          if (this.dataScope.preferences.filter) {
            this.dataScope.preferences.filter = this.dataScope.preferences.filter.filter((f) => {
              return f === 'OR' || !!Object.keys(f)[0]
            })
          }

          this.$emit('submit', this.dataScope)
        }
      })
    }
  }
}
</script>
