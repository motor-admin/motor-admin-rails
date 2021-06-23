<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataLink"
      @submit.prevent="submit"
    >
      <FormItem
        :label="i18n['name']"
        prop="name"
      >
        <VInput
          v-model="dataLink.name"
          :placeholder="i18n['link_name']"
          @keydown.enter="submit"
        />
      </FormItem>
      <FormItem
        :label="i18n['path']"
        prop="path"
      >
        <VInput
          v-model="dataLink.path"
          placeholder="/path"
          @keydown.enter="submit"
        />
      </FormItem>
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove', link)"
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
export default {
  name: 'LinkForm',
  props: {
    link: {
      type: Object,
      required: true
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['cancel', 'submit', 'remove'],
  data () {
    return {
      isLoading: false,
      dataLink: { ...this.link }
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true }],
        path: [{ required: true }]
      }
    }
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', [this.link, this.dataLink])
        }
      })
    }
  }
}
</script>
