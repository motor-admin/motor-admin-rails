<template>
  <div v-if="isSuccess">
    <p class="fs-2 fw-bold text-center mb-2">
      <Icon
        type="md-checkmark-circle-outline"
        class="text-success"
      />
      Form has been submitted successfully!
    </p>
    <div
      v-if="successData"
      class="mb-2"
    >
      <pre v-if="typeof successData === 'object'">{{ JSON.stringify(successData, null, '  ') }}</pre>
      <div
        v-else
        v-html="safeSuccessData"
      />
    </div>
    <VButton
      icon="md-refresh"
      size="large"
      ghost
      long
      type="primary"
      @click="reset"
    >
      Resubmit
    </VButton>
  </div>
  <VForm
    v-else
    ref="form"
    :model="formData"
    :rules="rules"
    label-position="top"
    @submit.prevent="handleSubmit"
  >
    <FormItem
      v-for="field in fields"
      :key="field.name"
      :label="field.display_name"
      :prop="field.name"
    >
      <FormInput
        v-model="formData[field.name]"
        :column="field"
      />
    </FormItem>
    <VButton
      type="primary"
      long
      size="large"
      :disabled="isSubmitDisabled"
      @click="handleSubmit"
    >
      Submit
    </VButton>
  </VForm>
  <Spin
    v-if="isLoading"
    fix
  />
</template>

<script>
import FormInput from 'data_forms/components/input'
import { interpolate } from 'utils/scripts/string'
import axios from 'axios'
import DOMPurify from 'dompurify'

export default {
  name: 'DataForm',
  components: {
    FormInput
  },
  props: {
    data: {
      type: Object,
      required: false,
      default: () => ({})
    },
    form: {
      type: Object,
      required: true
    }
  },
  emits: ['submit', 'success', 'error'],
  data () {
    return {
      isLoading: false,
      isSuccess: false,
      successData: null,
      formData: { ...this.data }
    }
  },
  computed: {
    safeSuccessData () {
      return DOMPurify.sanitize(this.successData)
    },
    isSubmitDisabled () {
      return !this.form.api_path
    },
    fields () {
      return this.form.preferences.fields
    },
    rules () {
      return this.fields.reduce((acc, field) => {
        if (field.validators?.length) {
          acc[field.name] = field.validators
        }

        return acc
      }, {})
    },
    defaultValues () {
      return this.fields.reduce((acc, field) => {
        if (field.default_value) {
          acc[field.name] = field.default_value
        }

        return acc
      }, {})
    }
  },
  created () {
    Object.assign(this.formData, this.defaultValues)
  },
  methods: {
    reset () {
      this.isSuccess = false
      this.successData = null
    },
    sendData () {
      const path = interpolate(this.form.api_path, this.formData)
      const method = this.form.http_method.toLowerCase()

      this.isLoading = true

      return axios[method](path, {
        ...this.formData
      }).then((result) => {
        this.$emit('success', result)
        this.formData = Object.assign({ ...this.data }, this.defaultValues)
        this.isSuccess = true
        this.successData = result.data
      }).catch((error) => {
        console.error(error)

        if (error.response?.data?.errors?.length) {
          this.$refs.form.setErrors(error.response.data.errors)
        }

        this.$Message.error(`Form failed with code ${error.response.status}`)

        this.$emit('error', error)
      }).finally(() => {
        this.isLoading = false
        this.$emit('submit', this.formData)
      })
    },
    handleSubmit () {
      if (!this.isSubmitDisabled) {
        this.$refs.form.validate((valid) => {
          if (valid) {
            this.sendData()
          }
        })
      }
    }
  }
}
</script>
