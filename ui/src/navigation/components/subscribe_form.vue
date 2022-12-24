<template>
  <VForm
    v-if="!isSubmitted"
    ref="form"
    :model="value"
    :rules="rules"
    @submit.prevent="handleSubmit"
    @keyup.enter="handleSubmit"
  >
    <div class="row">
      <div class="col-12 mb-3 text-center fs-3">
        Subscribe to receive developer newsletters with feature updates
      </div>
      <FormItem
        prop="email"
        class="col-12"
      >
        <VInput
          v-model="value.email"
          prefix="md-mail"
          type="email"
          name="email"
          :disabled="isSubmitted"
          size="large"
          placeholder="example@example.com"
        />
      </FormItem>
    </div>
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
      size="large"
      fix
    />
  </VForm>
  <div
    v-else
    class="fs-3"
  >
    <Icon
      type="md-checkmark-circle text-success"
    />
    You have been subscribed for newsletters
  </div>
</template>

<script>
import axios from 'axios'
import { currentUser } from '../scripts/user_store'

export default {
  name: 'SetupForm',
  props: {
    submitText: {
      type: String,
      required: false,
      default: 'Subscribe'
    }
  },
  emits: ['error', 'success'],
  data () {
    return {
      isLoading: false,
      isSubmitted: currentUser.isSubscribed,
      value: { email: currentUser.email }
    }
  },
  computed: {
    rules () {
      return {
        email: [{ required: true, type: 'email' }]
      }
    }
  },
  methods: {
    submit () {
      this.isLoading = true

      axios.post('https://app.getmotoradmin.com/api/subscribe', {
        email: this.value.email
      }).then((result) => {
        currentUser.isSubscribed = true

        this.$emit('success', result.data.data)
      }).catch((error) => {
        console.error(error)
        this.$emit('error', error)
      }).finally(() => {
        this.isSubmitted = true
        this.isLoading = false
      })
    },
    handleSubmit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.submit()
        }
      })
    }
  }
}
</script>
