<template>
  <VForm
    ref="form"
    :model="dataAlert"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      :label="i18n['name']"
      prop="name"
    >
      <VInput
        v-model="dataAlert.name"
        size="large"
        :autofocus="!dataAlert.id"
        :placeholder="i18n['alert_name']"
      />
    </FormItem>
    <FormItem
      :label="i18n['query']"
      prop="query_id"
    >
      <SelectQuery
        v-model="dataAlert.query_id"
        size="large"
        @update:modelValue="$emit('select-query', dataAlert.query_id)"
      />
    </FormItem>

    <FormItem
      :label="i18n['send_to']"
      prop="to_emails"
    >
      <MSelect
        v-model="dataAlert.to_emails"
        filterable
        allow-create
        multiple
        :options="dataAlert.to_emails"
        :placeholder="i18n['emails']"
        :size="'large'"
      />
    </FormItem>
    <div class="row">
      <div class="col-7">
        <FormItem
          :label="i18n['interval']"
          prop="preferences.interval"
        >
          <IntervalInput
            v-model="dataAlert.preferences.interval"
          />
        </FormItem>
      </div>
      <div class="col-5 ps-0">
        <FormItem
          :label="i18n['timezone']"
          prop="preferences.timezone"
        >
          <TimezoneSelect
            v-model="dataAlert.preferences.timezone"
            size="large"
          />
        </FormItem>
      </div>
    </div>
    <FormItem
      :label="i18n['send_empty']"
      prop="preferences.send_empty"
    >
      <Checkbox
        v-model="dataAlert.preferences.send_empty"
      />
    </FormItem>
    <FormItem
      :label="i18n['description']"
      prop="description"
    >
      <VInput
        v-model="dataAlert.description"
        type="textarea"
        :placeholder="i18n['describe_this_alert_optional']"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      :label="i18n['tags']"
      prop="tags"
    >
      <TagsSelect
        v-model="dataAlert.tags"
        :placeholder="i18n['select_alert_tags']"
      />
    </FormItem>
    <VButton
      v-if="withSubmit"
      size="large"
      class="mt-3"
      long
      type="primary"
      :loading="loading"
      @click="submit"
    >
      {{ i18n['save'] }}
    </VButton>
  </VForm>
</template>

<script>
import SelectQuery from 'queries/components/select'
import TagsSelect from 'tags/components/select'
import IntervalInput from 'utils/components/interval_input'
import TimezoneSelect from 'utils/components/timezone_select'
import { fieldRequiredMessage } from 'utils/scripts/i18n'

export default {
  name: 'AlertForm',
  components: {
    SelectQuery,
    TagsSelect,
    IntervalInput,
    TimezoneSelect
  },
  props: {
    alert: {
      type: Object,
      required: true
    },
    withSubmit: {
      type: Boolean,
      required: false,
      default: true
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'select-query', 'change-emails'],
  data () {
    return {
      dataAlert: {}
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true, message: fieldRequiredMessage('name') }],
        query_id: [{ required: true, message: fieldRequiredMessage('query') }],
        to_emails: [{ required: true, message: this.i18n.field_list_cant_be_empty.replace('%{field}', this.i18n.emails) }],
        'preferences.interval': [{ required: true, message: fieldRequiredMessage('interval') }],
        'preferences.timezone': [{ required: true, message: fieldRequiredMessage('timezone') }]
      }
    }
  },
  watch: {
    alert () {
      this.dataAlert = JSON.parse(JSON.stringify(this.normalizeAlert(this.alert)))
    }
  },
  created () {
    this.dataAlert = JSON.parse(JSON.stringify(this.normalizeAlert(this.alert)))
  },
  methods: {
    normalizeAlert (alert) {
      return {
        ...alert,
        to_emails: alert.to_emails.split(',').filter(Boolean),
        tags: alert.tags.map((tag) => tag.name)
      }
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', this.dataAlert)
        }
      })
    }
  }
}
</script>
