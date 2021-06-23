<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataTab"
      @submit.prevent
    >
      <FormItem
        v-if="withName"
        :label="i18n['name']"
        prop="display_name"
      >
        <VInput v-model="dataTab.display_name" />
      </FormItem>

      <div class="row">
        <div :class="dataTab.tab_type && dataTab.tab_type !== 'default' ? 'col-sm-4 pe-sm-1' : 'col-12'">
          <FormItem
            :label="i18n['tab_type']"
            prop="tab_type"
          >
            <MSelect
              v-model="dataTab.tab_type"
              :options="tabTypes"
              @update:modelValue="dataTab.preferences = {}"
            />
          </FormItem>
        </div>
        <div
          v-if="dataTab.tab_type && dataTab.tab_type !== 'default'"
          class="col-sm-8 ps-sm-1"
        >
          <FormItem
            v-if="dataTab.tab_type && dataTab.tab_type !== 'default'"
            :label="titleize(dataTab.tab_type)"
            :prop="`preferences.${dataTab.tab_type}_id`"
          >
            <FormSelect
              v-if="dataTab.tab_type === 'form'"
              v-model="dataTab.preferences.form_id"
            />
            <QuerySelect
              v-if="dataTab.tab_type === 'query'"
              v-model="dataTab.preferences.query_id"
            />
            <DashboardSelect
              v-if="dataTab.tab_type === 'dashboard'"
              v-model="dataTab.preferences.dashboard_id"
            />
          </FormItem>
        </div>
      </div>
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove && dataTab.name !== 'details'"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove')"
        >
          {{ i18n['remove'] }}
        </VButton>
        <VButton
          @click="$emit('cancel')"
        >
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
import { titleize } from 'utils/scripts/string'
import FormSelect from 'custom_forms/components/select'
import QuerySelect from 'queries/components/select'
import DashboardSelect from 'dashboards/components/select'

export default {
  name: 'ResourceTabForm',
  components: {
    FormSelect,
    QuerySelect,
    DashboardSelect
  },
  props: {
    tab: {
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
    },
    withName: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['cancel', 'submit', 'remove'],
  data () {
    return {
      isLoading: false,
      dataTab: {}
    }
  },
  computed: {
    rules () {
      const rules = {
        tab_type: [{ required: true }]
      }

      const key = this.tabTypeKeys[this.dataTab.tab_type]

      if (key) {
        rules[`preferences.${key}`] = [{ required: true }]
      }

      if (this.withName) {
        rules.display_name = [{ required: true }]
      }

      return rules
    },
    tabTypeKeys () {
      return {
        form: 'form_id',
        dashboard: 'dashboard_id',
        query: 'query_id'
      }
    },
    tabTypes () {
      const tabs = [
        { label: 'Dashboard', value: 'dashboard' },
        { label: 'Query', value: 'query' },
        { label: 'Form', value: 'form' }
      ]

      if (this.dataTab.name === 'details') {
        tabs.unshift({ label: 'Default', value: 'default' })
      }

      return tabs
    }
  },
  created () {
    this.dataTab = { ...this.tab }
  },
  methods: {
    titleize,
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', this.dataTab)
        }
      })
    }
  }
}
</script>
