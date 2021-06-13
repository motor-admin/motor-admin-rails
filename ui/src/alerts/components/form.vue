<template>
  <VForm
    ref="form"
    :model="dataAlert"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      label="Name"
      prop="name"
    >
      <VInput
        v-model="dataAlert.name"
        size="large"
        placeholder="Alert name"
      />
    </FormItem>
    <FormItem
      label="Query"
      prop="query_id"
    >
      <SelectQuery
        v-model="dataAlert.query_id"
        size="large"
        @update:modelValue="$emit('select-query', dataAlert.query_id)"
      />
    </FormItem>

    <FormItem
      label="Send to"
      prop="to_emails"
    >
      <MSelect
        v-model="dataAlert.to_emails"
        filterable
        allow-create
        multiple
        :options="dataAlert.to_emails"
        placeholder="Emails"
        :size="'large'"
      />
    </FormItem>
    <div class="row">
      <div class="col-7">
        <FormItem
          label="Interval"
          prop="preferences.interval"
        >
          <IntervalInput
            v-model="dataAlert.preferences.interval"
          />
        </FormItem>
      </div>
      <div class="col-5 ps-0">
        <FormItem
          label="Timezone"
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
      label="Send empty?"
      prop="preferences.send_empty"
    >
      <Checkbox
        v-model="dataAlert.preferences.send_empty"
      />
    </FormItem>
    <FormItem
      label="Description"
      prop="description"
    >
      <VInput
        v-model="dataAlert.description"
        type="textarea"
        placeholder="Describe this alert (optional)"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      label="Tags"
      prop="tags"
    >
      <TagsSelect
        v-model="dataAlert.tags"
        placeholder="Select alert tags"
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
      Save
    </VButton>
  </VForm>
</template>

<script>
import SelectQuery from 'queries/components/select'
import TagsSelect from 'tags/components/select'
import IntervalInput from 'utils/components/interval_input'
import TimezoneSelect from 'utils/components/timezone_select'

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
        name: [{ required: true }],
        query_id: [{ required: true }],
        to_emails: [{ required: true }],
        'preferences.interval': [{ required: true }],
        'preferences.timezone': [{ required: true }]
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
        to_emails: alert.to_emails.split(','),
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
