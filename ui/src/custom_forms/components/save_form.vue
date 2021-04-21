<template>
  <VForm
    ref="form"
    :model="dataForm"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      label="Name"
      prop="name"
    >
      <VInput
        v-model="dataForm.name"
        size="large"
        placeholder="Form name"
      />
    </FormItem>

    <div class="row">
      <FormItem
        label="Method"
        prop="http_method"
        class="col-3 pe-0"
      >
        <MSelect
          v-model="dataForm.http_method"
          :options="['POST', 'PUT']"
        />
      </FormItem>

      <FormItem
        label="Path"
        prop="api_path"
        class="col-9"
      >
        <VInput
          v-model="dataForm.api_path"
          :placeholder="'/api/path/{id}...'"
        />
      </FormItem>
    </div>
    <FormItem
      label="Description"
      prop="description"
    >
      <VInput
        v-model="dataForm.description"
        type="textarea"
        placeholder="Describe your form (optional)"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      label="Tags"
      prop="tags"
    >
      <TagsSelect
        v-model="dataForm.tags"
        placeholder="Select dashform tags"
      />
    </FormItem>
    <VButton
      size="large"
      class="mt-3"
      long
      type="primary"
      @click="submit"
    >
      Save
    </VButton>
  </VForm>
</template>

<script>
import api from 'api'
import TagsSelect from 'tags/components/select'

export default {
  name: 'SaveCustomForm',
  components: {
    TagsSelect
  },
  props: {
    form: {
      type: Object,
      required: true
    }
  },
  emits: ['success'],
  data () {
    return {
      dataForm: {}
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true }],
        api_path: [{ required: true }],
        http_method: [{ required: true }]
      }
    },
    apiRequest () {
      const params = {
        data: this.dataForm,
        include: 'tags'
      }

      if (this.form.id) {
        return api.put(`forms/${this.dataForm.id}`, params)
      } else {
        return api.post('forms', params)
      }
    }
  },
  created () {
    this.dataForm = JSON.parse(JSON.stringify(this.form))
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.apiRequest.then((result) => {
            this.$emit('success', result.data.data)
          }).catch((error) => {
            if (error.response.data.errors?.length) {
              this.$refs.form.setErrors(error.response.data.errors)
            }
          })
        }
      })
    }
  }
}
</script>
