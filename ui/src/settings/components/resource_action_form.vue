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
        label="Name"
        prop="display_name"
      >
        <VInput v-model="dataAction.display_name" />
      </FormItem>

      <div class="row">
        <div :class="dataAction.action_type && dataAction.action_type !== 'default' ? 'col-sm-4 pe-sm-1' : 'col-12'">
          <FormItem
            label="Action type"
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
            label="Form"
            prop="preferences.form_id"
          >
            <FormSelect v-model="dataAction.preferences.form_id" />
          </FormItem>
          <FormItem
            v-if="dataAction.action_type === 'method'"
            label="Method"
            prop="preferences.method_name"
          >
            <MethodSelect
              v-model="dataAction.preferences.method_name"
              :resource-slug="resource.slug"
            />
          </FormItem>
          <FormItem
            v-if="dataAction.action_type === 'api'"
            label="API path"
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
          Remove
        </VButton>
        <VButton
          @click="$emit('cancel')"
        >
          Cancel
        </VButton>
      </div>
      <VButton
        type="primary"
        :loading="isLoading"
        @click="submit"
      >
        Save
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
