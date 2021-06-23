<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataAction"
      @submit.prevent
    >
      <FormItem
        v-if="withName"
        :label="i18n['name']"
        prop="display_name"
      >
        <VInput v-model="dataAction.display_name" />
      </FormItem>

      <div class="row">
        <div :class="dataAction.action_type && dataAction.action_type !== 'default' ? 'col-sm-4 pe-sm-1' : 'col-12'">
          <FormItem
            :label="i18n['action_type']"
            prop="action_type"
          >
            <MSelect
              v-model="dataAction.action_type"
              :options="actionTypes"
              @update:modelValue="dataAction.preferences = {}"
            />
          </FormItem>
        </div>
        <div
          v-if="dataAction.action_type && dataAction.action_type !== 'default'"
          class="col-sm-8 ps-sm-1"
        >
          <FormItem
            v-if="dataAction.action_type === 'form'"
            :label="i18n['form']"
            prop="preferences.form_id"
          >
            <FormSelect v-model="dataAction.preferences.form_id" />
          </FormItem>
          <FormItem
            v-if="dataAction.action_type === 'method'"
            :label="i18n['method']"
            prop="preferences.method_name"
          >
            <MethodSelect
              v-model="dataAction.preferences.method_name"
              :resource-slug="resource.slug"
            />
          </FormItem>
          <FormItem
            v-if="dataAction.action_type === 'api'"
            :label="i18n['api_path']"
            prop="preferences.api_path"
          >
            <VInput v-model="dataAction.preferences.api_path" />
          </FormItem>
        </div>
      </div>
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove && !isCrudAction"
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
import MethodSelect from './resource_method_select'
import FormSelect from 'custom_forms/components/select'

export default {
  name: 'ResourceActionForm',
  components: {
    MethodSelect,
    FormSelect
  },
  props: {
    action: {
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
      dataAction: {}
    }
  },
  computed: {
    rules () {
      const rules = {
        action_type: [{ required: true }]
      }

      const key = this.actionTypeKeys[this.dataAction.action_type]

      if (key) {
        rules[`preferences.${key}`] = [{ required: true }]
      }

      if (this.withName) {
        rules.display_name = [{ required: true }]
      }

      return rules
    },
    actionTypeKeys () {
      return {
        api: 'api_path',
        method: 'method_name',
        form: 'form_id'
      }
    },
    isCrudAction () {
      return ['create', 'edit', 'remove'].includes(this.dataAction.name)
    },
    actionTypes () {
      const actions = [
        { label: 'Form', value: 'form' }
      ]

      if (!['create', 'edit'].includes(this.dataAction.name)) {
        actions.unshift(
          { label: 'Method call', value: 'method' },
          { label: 'API request', value: 'api' }
        )
      }

      if (this.isCrudAction) {
        actions.unshift({ label: 'Default', value: 'default' })
      }

      return actions
    }
  },
  created () {
    this.dataAction = { ...this.action }
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', this.dataAction)
        }
      })
    }
  }
}
</script>
