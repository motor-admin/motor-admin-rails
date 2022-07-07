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
        <div
          v-if="actionTypes.length > 1"
          :class="dataAction.action_type && dataAction.action_type !== 'default' ? 'col-sm-4 pe-sm-1' : 'col-12'"
        >
          <FormItem
            :label="i18n['action_type']"
            prop="action_type"
          >
            <MSelect
              v-model="dataAction.action_type"
              :options="actionTypes"
              :placeholder="i18n['select']"
              @update:model-value="dataAction.preferences = {}"
            />
          </FormItem>
        </div>
        <div
          v-if="dataAction.action_type && dataAction.action_type !== 'default'"
          :class="actionTypes.length === 1 ? 'col-12' : 'col-sm-8 ps-sm-1'"
        >
          <FormItem
            v-if="dataAction.action_type === 'form'"
            :label="i18n['form']"
            prop="preferences.form_id"
          >
            <FormSelect
              v-model="dataAction.preferences.form_id"
              :with-create-button="true"
              :create-params="{ resource: resource.name, action: dataAction.display_name }"
            />
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
        </div>
        <Checkbox
          v-if="dataAction.action_type === 'form'"
          :model-value="dataAction.apply_on === 'collection'"
          class="d-block mb-4"
          @update:model-value="toggleApplyOn"
        >
          {{ ' ' }} {{ i18n['on_collection'] }}
        </Checkbox>
        <Checkbox
          v-if="dataAction.apply_on !== 'collection'"
          v-model="dataAction.preferences.show_on_table"
          class="d-block mb-4"
        >
          {{ ' ' }} {{ i18n['show_on_table'] }}
        </Checkbox>
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
import { fieldRequiredMessage } from 'utils/scripts/i18n'
import { isStandalone } from 'utils/scripts/configs'

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
    isStandalone: () => isStandalone,
    rules () {
      const rules = {
        action_type: [{
          required: true,
          message: fieldRequiredMessage('action_type')
        }]
      }

      const key = this.actionTypeKeys[this.dataAction.action_type]

      if (key) {
        rules[`preferences.${key}`] = [{
          required: true,
          message: fieldRequiredMessage(this.dataAction.action_type)
        }]
      }

      if (this.withName) {
        rules.display_name = [{
          required: true,
          message: fieldRequiredMessage('name')
        }]
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
        { label: this.i18n.form, value: 'form' }
      ]

      if (!['create', 'edit'].includes(this.dataAction.name)) {
        if (!isStandalone) {
          actions.unshift(
            { label: this.i18n.method_call, value: 'method' }
          )
        }
      }

      if (this.isCrudAction) {
        actions.unshift({ label: this.i18n.default, value: 'default' })
      }

      return actions
    }
  },
  created () {
    this.dataAction = JSON.parse(JSON.stringify(this.action))
  },
  methods: {
    toggleApplyOn (value) {
      if (value) {
        this.dataAction.apply_on = 'collection'
      } else {
        this.dataAction.apply_on = 'member'
      }
    },
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
