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
        label="Name"
        prop="name"
      >
        <VInput
          v-model="dataLink.name"
          placeholder="Link name"
          @keydown.enter="submit"
        />
      </FormItem>
      <FormItem
        label="Path"
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
export default {
  name: 'HeaderLinkForm',
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
