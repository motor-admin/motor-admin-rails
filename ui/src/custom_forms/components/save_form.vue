<template>
  <VForm
    ref="form"
    :model="dataForm"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      :label="i18n['name']"
      prop="name"
    >
      <VInput
        v-model="dataForm.name"
        size="large"
        :autofocus="true"
        :placeholder="i18n['form_name']"
      />
    </FormItem>

    <div class="row">
      <FormItem
        :label="i18n['method']"
        prop="http_method"
        class="col-3 pe-0"
      >
        <MSelect
          v-model="dataForm.http_method"
          :with-deselect="false"
          :options="['POST', 'PUT']"
        />
      </FormItem>

      <FormItem
        :label="i18n['path']"
        prop="api_path"
        class="col-9"
      >
        <VInput
          v-model="dataForm.api_path"
          :placeholder="'/api/path/{id}...'"
        />
      </FormItem>
    </div>
    <div class="row">
      <FormItem
        :label="i18n['load_initial_data']"
        class="col-3 pe-0"
      >
        <Checkbox
          v-model="loadDefault"
        />
      </FormItem>

      <FormItem
        v-if="loadDefault"
        :label="i18n['api_path']"
        prop="default_values_api_path"
        class="col-9"
      >
        <VInput
          v-model="dataForm.preferences.default_values_api_path"
          :placeholder="'/api/path/{id}...'"
        />
      </FormItem>
    </div>
    <FormItem
      :label="i18n['description']"
      prop="description"
    >
      <VInput
        v-model="dataForm.description"
        type="textarea"
        :placeholder="i18n['describe_your_form_optional']"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      :label="i18n['tags']"
      prop="tags"
    >
      <TagsSelect
        v-model="dataForm.tags"
        :placeholder="i18n['select_form_tags']"
      />
    </FormItem>
    <VButton
      size="large"
      class="mt-3"
      long
      type="primary"
      @click="submit"
    >
      {{ i18n['save'] }}
    </VButton>
  </VForm>
</template>

<script>
import api from 'api'
import TagsSelect from 'tags/components/select'
import { fieldRequiredMessage } from 'utils/scripts/i18n'

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
      loadDefault: false,
      dataForm: {}
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true, message: fieldRequiredMessage('name') }],
        api_path: [{ required: true, message: fieldRequiredMessage('path') }],
        http_method: [{ required: true, message: fieldRequiredMessage('method') }]
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

    this.loadDefault = !!this.dataForm.preferences.default_values_api_path
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.apiRequest.then((result) => {
            this.$emit('success', result.data.data)
          }).catch((error) => {
            if (error.response.data?.errors?.length) {
              this.$refs.form.setErrors(error.response.data.errors)
            }
          })
        }
      })
    }
  }
}
</script>
