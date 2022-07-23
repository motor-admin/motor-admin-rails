<template>
  <div class="bg-white">
    <Tabs
      v-model="selectedTab"
      :position="'center'"
      :tabs="[
        { label: i18n['visualization'], value: 'visualization' },
        { label: i18n['variables'], value: 'variables' },
      ]"
    />
    <div
      :style="{
        height: `calc(var(--vh, 100vh) - 224px)`,
        overflowY: 'auto'
      }"
      class="p-2"
    >
      <template v-if="selectedTab === 'variables'">
        <template v-if="withVariablesEditor || preferences.variables.length">
          <Card
            v-for="(variable, index) in preferences.variables"
            :key="index"
            class="my-2"
          >
            <div
              v-if="!withVariablesEditor"
              class="fw-bold mb-3"
            >
              {{ variable.display_name }}
            </div>
            <VariableSettings
              :variable="variable"
              :with-name="withVariablesEditor"
              :with-remove="withVariablesEditor"
              @remove="preferences.variables.splice(index, 1)"
            />
          </Card>
          <VButton
            v-if="withVariablesEditor"
            icon="md-add"
            long
            @click="addNewVariable"
          >
            {{ i18n.add_variable }}
          </VButton>
        </template>
        <VariablesHint v-else />
      </template>
      <template v-else>
        <p class="fs-4 fw-bold my-1">
          {{ i18n['display_as'] }}
        </p>
        <RadioGroup
          v-model="preferences.visualization"
          class="d-flex flex-column"
        >
          <Radio
            v-for="option in visualizationOptions"
            :key="option.value"
            :label="option.value"
            border
            size="large"
            class="my-1 me-0"
            @update:model-value="maybeSetLabelFormat"
          >
            {{ option.label }}
          </Radio>
        </RadioGroup>
        <template v-if="['bar_chart', 'row_chart', 'line_chart', 'funnel'].includes(preferences.visualization)">
          <Checkbox
            v-model="preferences.visualization_options.chart_values_axis"
            class="d-block"
          >
            {{ ' ' }} {{ i18n['values_axis'] }}
          </Checkbox>
          <Checkbox
            v-if="['bar_chart', 'row_chart'].includes(preferences.visualization)"
            v-model="preferences.visualization_options.chart_stacked"
            class="d-block"
          >
            {{ ' ' }} {{ i18n['stacked_bars'] }}
          </Checkbox>
        </template>
        <template v-if="!['table', 'markdown', 'html', 'value', 'map'].includes(preferences.visualization)">
          <p class="fs-4 fw-bold my-1">
            Format
          </p>
          <RadioGroup
            v-model="preferences.visualization_options.label_format"
            class="d-flex flex-column"
            @update:model-value="maybeSetCurrency"
          >
            <Radio
              v-for="option in formatOptions"
              :key="option.value"
              :label="option.value"
              border
              size="large"
              class="my-1 me-0"
            >
              {{ option.label }}
            </Radio>
          </RadioGroup>
        </template>
        <template v-if="!['table', 'markdown', 'html'].includes(preferences.visualization) && preferences.visualization_options.label_format === 'currency'">
          <p class="fs-4 fw-bold my-1">
            {{ i18n['currency'] }}
          </p>
          <CurrencySelect
            v-model="preferences.visualization_options.label_format_options.currency"
          />
        </template>
      </template>
    </div>
    <div class="footer p-2">
      <VButton
        long
        type="default"
        @click="$emit('close')"
      >
        {{ i18n['ok'] }}
      </VButton>
    </div>
  </div>
</template>

<script>
import CurrencySelect from 'utils/components/currency_select'
import Tabs from 'utils/components/tabs'
import VariableSettings from '../components/variable_settings'
import VariablesHint from './variables_hint'

export default {
  name: 'QuerySettings',
  components: {
    CurrencySelect,
    Tabs,
    VariableSettings,
    VariablesHint
  },
  props: {
    preferences: {
      type: Object,
      required: true
    },
    columns: {
      type: Array,
      required: false,
      default: () => []
    },
    withVariablesEditor: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['close'],
  data () {
    return {
      selectedTab: 'visualization'
    }
  },
  computed: {
    visualizationOptions () {
      return [
        { label: this.i18n.table, value: 'table' },
        { label: this.i18n.value, value: 'value' },
        { label: this.i18n.markdown, value: 'markdown' },
        { label: this.i18n.html, value: 'html' },
        { label: this.i18n.line_chart, value: 'line_chart' },
        { label: this.i18n.bar_chart, value: 'bar_chart' },
        { label: this.i18n.row_chart, value: 'row_chart' },
        { label: this.i18n.pie_chart, value: 'pie_chart' },
        { label: this.i18n.radar_chart, value: 'radar_chart' },
        { label: this.i18n.funnel, value: 'funnel' },
        { label: this.i18n.map, value: 'map' }
      ]
    },
    formatOptions () {
      return [
        { label: this.i18n.decimal, value: 'decimal' },
        { label: this.i18n.percent, value: 'percent' },
        { label: this.i18n.currency, value: 'currency' }
      ]
    }
  },
  methods: {
    maybeSetLabelFormat (value) {
      if (!['table', 'markdown', 'html'].includes(value)) {
        this.preferences.visualization_options.label_format ||= 'decimal'
        this.preferences.visualization_options.label_format_options ||= {}
      }
    },
    addNewVariable () {
      this.preferences.variables.push({
        name: '',
        display_name: 'New variable',
        variable_type: 'text'
      })
    },
    maybeSetCurrency (value) {
      if (value === 'currency') {
        this.preferences.visualization_options.label_format_options ||= {}
        this.preferences.visualization_options.label_format_options.currency ||= 'USD'
      }
    }
  }
}
</script>

<style lang="scss" scoped>
:deep(.ivu-tabs-bar) {
  margin-bottom: 0px
}

.footer {
  width: 100%;
  position: sticky;
  bottom: 0;
  left: 0;
  border-top: 1px solid #e8e8e8;
  padding-top: 8px;
  text-align: right;
  background: #fff;
}
</style>
