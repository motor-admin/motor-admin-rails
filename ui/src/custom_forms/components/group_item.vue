<template>
  <Collapse
    simple
    class="mb-3"
    style="margin: 0 -16px"
    :model-value="'1'"
  >
    <Panel name="1">
      {{ item.display_name }}
      <template #content>
        <VueDraggableNext
          v-if="item.is_array"
          :list="formData"
          handle=".handle"
        >
          <div
            v-for="(data, index) in formData"
            :key="index"
            class="ivu-card ivu-card-bordered mb-2"
          >
            <div class="ivu-card-body py-0">
              <div
                class="d-flex align-items-center justify-content-between py-2"
              >
                <div class="d-flex align-items-center py-1">
                  <Icon
                    type="ios-menu"
                    class="me-3 cursor-grab handle"
                  />
                </div>
                <div class="d-flex align-items-center py-1">
                  <Icon
                    type="md-trash"
                    class="cursor-pointer"
                    @click="formData.splice(index, 1)"
                  />
                </div>
              </div>
              <FormItems
                v-model:form-data="formData[index]"
                :items="item.items"
                :variables-data="{ ...variablesData, ...formData[index] }"
                :prop-prefix="propPrefix ? `${propPrefix}.${index}` : `${item.name}.${index}`"
              />
            </div>
          </div>
          <div
            class="text-center my-2"
          >
            <VButton
              long
              type="text"
              icon="md-add"
              class="me-1"
              @click="formData.push(buildDefaultValues(item.items))"
            >
              {{ i18n['add_item'] }}
            </VButton>
          </div>
        </VueDraggableNext>
        <FormItems
          v-else
          v-model:form-data="formData"
          :items="item.items"
          :variables-data="{ ...variablesData, ...formData }"
          :prop-prefix="propPrefix ? propPrefix : item.name"
        />
      </template>
    </Panel>
  </Collapse>
</template>

<script>
import { defineAsyncComponent } from 'vue'
import { buildDefaultValues } from '../scripts/utils'

const FormItems = defineAsyncComponent(() => import('./form_items'))

export default {
  name: 'GroupItem',
  components: {
    FormItems
  },
  props: {
    formData: {
      type: Object,
      required: true
    },
    variablesData: {
      type: Object,
      required: false,
      default: () => ({})
    },
    propPrefix: {
      type: String,
      required: false,
      default: ''
    },
    item: {
      type: Object,
      required: true
    }
  },
  methods: {
    buildDefaultValues
  }
}
</script>

<style lang="scss" scoped>
:deep(.ivu-collapse-content-box) {
  padding: 10px 0 0 0 !important;
}
</style>
