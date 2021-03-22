<template>
  <div class="bg-white p-2">
    <div style="height: calc(100% - 43px); overflow-y: scroll">
      <h3 class="my-1">
        Visualize
      </h3>
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
      const options = [
        { label: 'Table', value: 'table' }
      ]

      if (this.columns.length > 1) {
        options.push(...[
          { label: 'Line chart', value: 'line_chart' },
          { label: 'Bar chart', value: 'bar_chart' }
        ])
      }

      if (this.columns.length === 2) {
        options.push(...[
          { label: 'Pie chart', value: 'pie_chart' }
        ])
      }

      return options
    }
  },
  mounted () {
    this.preferences.visualization ||= 'table'
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
  padding: 8px 0;
  text-align: right;
  background: #fff;
}
</style>
