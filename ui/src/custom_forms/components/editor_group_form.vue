<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataGroup"
      @submit.prevent="submit"
    >
      <FormItem
        :label="i18n['name']"
        prop="display_name"
        :class="dataGroup.display_name && !isCustomName ? 'mb-0' : ''"
      >
        <VInput
          ref="nameInput"
          v-model="dataGroup.display_name"
          :placeholder="i18n['group_name']"
          @drag.stop
        />
      </FormItem>
      <p
        v-if="!isCustomName && generatedParamName"
        style="margin-bottom: 6px; font-size: 12px"
      >
        {{ i18n['param_name'] }}: <code>{{ generatedParamName }}</code>
        <Icon
          type="md-create"
          class="ms-1 cursor-pointer"
          @click="toggleCustomParam"
        />
      </p>
      <FormItem
        v-if="isCustomName"
        :label="i18n['param_name']"
        prop="name"
      >
        <VInput
          v-model="dataGroup.name"
          :placeholder="i18n['request_param']"
          @drag.stop
        />
      </FormItem>
      <Checkbox
        v-model="dataGroup.is_array"
        class="d-block"
      >
        {{ ' ' }} {{ i18n['multiple'] }}
      </Checkbox>
      <Checkbox
        :model-value="isConditional"
        class="d-block mb-3"
        @update:model-value="toggleConditional"
      >
        {{ ' ' }} {{ i18n['conditional'] }}
      </Checkbox>
      <FieldCondition
        v-if="isConditional"
        v-model="dataGroup.conditions[0]"
        :fields="conditionFields"
      />
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
        <VButton
          @click="$emit('cancel')"
        >
          {{ i18n['cancel'] }}
        </VButton>
      </div>
      <VButton
        type="primary"
        @click="submit"
      >
        {{ okText }}
      </VButton>
    </div>
  </div>
</template>

<script>
import { underscore } from 'utils/scripts/string'
import { i18nDict, fieldRequiredMessage } from 'utils/scripts/i18n'
import FieldCondition from './editor_field_condition'

export default {
  name: 'GroupForm',
  components: {
    FieldCondition
  },
  props: {
    group: {
      type: Object,
      required: true
    },
    okText: {
      type: String,
      required: false,
      default: i18nDict.ok
    },
    conditionFields: {
      type: Array,
      required: false,
      default: () => []
    },
    focus: {
      type: Boolean,
      required: false,
      default: false
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'remove', 'cancel'],
  data () {
    return {
      dataGroup: {},
      isCustomName: false
    }
  },
  computed: {
    rules () {
      return {
        display_name: [{ required: true, message: fieldRequiredMessage('name') }],
        name: [{ required: true, message: fieldRequiredMessage('param_name') }]
      }
    },
    isConditional () {
      return !!this.dataGroup.conditions?.length
    },
    generatedParamName () {
      const name = underscore(this.dataGroup.display_name)

      return name
    }
  },
  mounted () {
    if (this.focus) {
      this.$refs.nameInput.$el.querySelector('input').focus()
    }
  },
  created () {
    this.dataGroup = JSON.parse(JSON.stringify(this.group))

    if (this.dataGroup.display_name) {
      this.isCustomName = this.generatedParamName !== this.dataGroup.name
    }
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          if (!this.isCustomName) {
            this.dataGroup.name = this.generatedParamName
          }

          if (this.dataGroup.conditions && !this.dataGroup.conditions[0]?.field) {
            this.dataGroup.conditions = []
          }

          this.$emit('submit', this.dataGroup)
        }
      })
    },
    toggleConditional () {
      this.dataGroup.conditions ||= []

      if (this.isConditional) {
        this.dataGroup.conditions = []
      } else {
        this.dataGroup.conditions = [{ field: '', action: 'eq', value: '' }]
      }
    },
    toggleCustomParam () {
      this.isCustomName = true

      this.dataGroup.name = this.generatedParamName
    }
  }
}
</script>

<style lang="scss" scoped>
.cursor-pointer {
  display: none
}

p:hover {
  .cursor-pointer {
    display: inline
  }
}
</style>
