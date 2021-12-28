<template>
  <VForm
    ref="form"
    :model="dataConfig"
    :rules="rules"
    @submit.prevent="handleSubmit"
  >
    <FormItem
      v-if="withName"
      prop="name"
      label="Name"
      class="col-12"
    >
      <VInput
        v-model="dataConfig.name"
        type="text"
        placeholder="API name"
      />
    </FormItem>
    <FormItem
      prop="url"
      label="URL"
      class="col-12"
    >
      <VInput
        v-model="dataConfig.url"
        type="text"
        placeholder="URL"
      />
    </FormItem>
    <FormItem
      prop="description"
      label="Description"
      class="col-12"
    >
      <VInput
        v-model="dataConfig.description"
        type="textarea"
        :autosize="{ minRows: 3, maxRows: 6 }"
        placeholder="API Description"
      />
    </FormItem>
    <FormItem
      prop="credentials.headers"
      label="Headers"
      class="col-12"
    >
      <KeyValueInput v-model="dataConfig.credentials.headers" />
    </FormItem>
    <VButton
      type="primary"
      class="mt-1"
      size="large"
      long
      @click="handleSubmit"
    >
      {{ submitText }}
    </VButton>
    <Spin
      v-if="isLoading"
      fix
    />
  </VForm>
</template>

<script>
import KeyValueInput from 'data_forms/components/key_value_input'

export default {
  name: 'ApiForm',
  components: {
    KeyValueInput
  },
  props: {
    config: {
      type: Object,
      required: false,
      default: () => ({ credentials: {}, preferences: {} })
    },
    withName: {
      type: Boolean,
      required: false,
      default: false
    },
    submitText: {
      type: String,
      required: false,
      default: 'Submit'
    }
  },
  emits: ['success', 'error', 'submit'],
  data () {
    return {
      isLoading: false,
      dataConfig: {}
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true }],
        url: [{ required: true }]
      }
    }
  },
  watch: {
    configs () {
      this.dataConfig = { ...this.config }
    }
  },
  created () {
    this.dataConfig = { ...this.config }
  },
  methods: {
    handleSubmit (e) {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', this.dataConfig)
        }
      })
    }
  }
}
</script>
