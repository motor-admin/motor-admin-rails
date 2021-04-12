<template>
  <div class="bg-white p-2">
    <div
      style="height: calc(100vh - 192px); overflow-y: scroll"
      class="pb-2"
    >
      <p class="fs-4 fw-bold my-1">
        Visualize
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
        >
          {{ option.label }}
        </Radio>
      </RadioGroup>
      <template v-if="preferences.visualization !== 'table'">
        <p class="fs-4 fw-bold my-1">
          Format
        </p>
        <RadioGroup
          v-model="preferences.format.style"
          class="d-flex flex-column"
          @update:modelValue="maybeSetCurrency"
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
      <template v-if="preferences.visualization !== 'table' && preferences.format.style === 'currency'">
        <p class="fs-4 fw-bold my-1">
          Currency
        </p>

        <VSelect
          v-model="preferences.format.options.currency"
          filterable
        >
          <VOption
            v-for="option in currencyOptions"
            :key="option"
            :value="option"
          >
            {{ option }}
          </VOption>
        </VSelect>
      </template>
    </div>
    <div class="footer">
      <VButton
        long
        type="default"
        @click="$emit('close')"
      >
        OK
      </VButton>
    </div>
  </div>
</template>

<script>
import { ISO_CODES } from 'utils/scripts/currencies'

export default {
  name: 'QuerySettings',
  props: {
    preferences: {
      type: Object,
      required: true
    },
    columns: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['close'],
  computed: {
    visualizationOptions () {
      return [
        { label: 'Table', value: 'table' },
        { label: 'Line chart', value: 'line_chart' },
        { label: 'Bar chart', value: 'bar_chart' },
        { label: 'Row chart', value: 'row_chart' },
        { label: 'Pie chart', value: 'pie_chart' },
        { label: 'Funnel', value: 'funnel' }
      ]
    },
    currencyOptions () {
      return ISO_CODES
    },
    formatOptions () {
      return [
        { label: 'Decimal', value: 'decimal' },
        { label: 'Percent', value: 'percent' },
        { label: 'Currency', value: 'currency' }
      ]
    }
  },
  created () {
    this.preferences.visualization ||= 'table'
    this.preferences.format ||= { style: 'decimal', options: {} }
  },
  methods: {
    maybeSetCurrency (value) {
      if (value === 'currency') {
        this.preferences.format.options.currency ||= 'USD'
      }
    }
  }
}
</script>

<style lang="scss" scoped>
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
