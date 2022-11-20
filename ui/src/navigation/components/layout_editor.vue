<template>
  <div>
    <Card
      v-for="(item, index) in dataValue"
      :key="index"
      class="mb-2"
    >
      <DashboardSelect
        v-model="item.id"
        :with-deselect="false"
      />
      <div
        v-if="item.conditions"
        class="d-flex justify-content-between mt-2"
      >
        <MSelect
          v-model="item.conditions[0].field"
          style="width: 49%"
          :options="['role', 'email']"
          :with-deselect="false"
          :placeholder="i18n.field"
        />
        <VInput
          v-model="item.conditions[0].value"
          style="width: 49%"
          :placeholder="i18n.value"
        />
      </div>
      <VButton
        :icon="item.conditions ? 'md-close' : 'md-add'"
        type="text"
        class="bg-transparent"
        long
        @click="toggleCondition(index)"
      >
        {{ item.conditions ? i18n.remove_condition : i18n.add_condition }}
      </VButton>
      <VButton
        icon="md-close"
        type="text"
        long
        class="bg-transparent text-danger"
        @click="removeItem(index)"
      >
        {{ i18n.remove }}
      </VButton>
    </Card>
    <div class="text-center">
      <VButton
        long
        icon="md-add"
        type="default"
        class="mb-2"
        @click="addNewItem"
      >
        {{ i18n.add_dashboard }}
      </VButton>
      <VButton
        long
        type="primary"
        @click="$emit('submit', dataValue)"
      >
        {{ i18n.save }}
      </VButton>
    </div>
  </div>
</template>

<script>
import DashboardSelect from 'dashboards/components/select'

export default {
  name: 'LayoutEditor',
  components: {
    DashboardSelect
  },
  props: {
    modelValue: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['submit'],
  data () {
    return {
      dataValue: []
    }
  },
  created () {
    this.dataValue = JSON.parse(JSON.stringify(this.modelValue))
  },
  methods: {
    toggleCondition (index) {
      if (this.dataValue[index].conditions) {
        delete this.dataValue[index].conditions
      } else {
        this.dataValue[index].conditions = [{ field: 'role', value: '' }]
      }
    },
    addNewItem () {
      this.dataValue.push({ type: 'dashboard', id: '' })
    },
    removeItem (index) {
      this.dataValue.splice(index, 1)
    }
  }
}
</script>
