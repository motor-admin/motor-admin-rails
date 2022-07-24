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
    <FormItem
      :label="i18n['api']"
      prop="api_config_name"
    >
      <div class="d-flex">
        <ApiSelect
          v-model="dataForm.api_config_name"
        />
        <VButton
          icon="md-settings"
          class="ms-2"
          @click="openApiSettings"
        />
      </div>
    </FormItem>
    <div class="mb-4">
      <RadioGroup
        v-model="dataForm.preferences.request_type"
        class="d-flex"
      >
        <Radio
          v-for="(option, index) in formTypes"
          :key="option.value"
          :label="option.value"
          border
          size="large"
          :style="index !== 0 ? 'margin-left: 15px !important' : ''"
          class="my-1 me-0 w-100"
          @update:model-value="changeFormType"
        >
          {{ option.label }}
        </Radio>
      </RadioGroup>
    </div>
    <div
      v-if="!dataForm.preferences.request_type || dataForm.preferences.request_type === 'rest'"
      class="row"
    >
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
    <CodeEditor
      v-else-if="dataForm.preferences.request_type === 'graphql'"
      v-model="dataForm.preferences.graphql_mutation"
      language="graphqlschema"
      :autofocus="true"
      :columns="graphqlColumns"
      class="mb-2"
      style="height: 200px"
      :placeholder="'mutation { }'"
    />
    <div class="row">
      <FormItem
        :label="i18n['load_initial_data']"
        class="col-3 pe-0"
      >
        <Checkbox v-model="loadDefault" />
      </FormItem>

      <FormItem
        v-if="loadDefault && (!dataForm.preferences.request_type || dataForm.preferences.request_type === 'rest')"
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
    <CodeEditor
      v-if="loadDefault && dataForm.preferences.request_type === 'graphql'"
      v-model="dataForm.preferences.graphql_query"
      language="graphqlschema"
      :columns="graphqlColumns"
      class="mb-2"
      style="height: 200px"
      :placeholder="'query { }'"
    />
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
import ApiSelect from 'api_configs/components/select'
import ApiSettings from 'api_configs/components/list'
import CodeEditor from 'utils/components/code_editor'

export default {
  name: 'SaveCustomForm',
  components: {
    TagsSelect,
    ApiSelect,
    CodeEditor
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
      dataForm: { preferences: { request_type: 'rest' } }
    }
  },
  computed: {
    formTypes () {
      return [
        { value: 'rest', label: 'REST' },
        { value: 'graphql', label: 'GraphQL' }
      ]
    },
    graphqlColumns () {
      return [
        { name: '$form_data' },
        ...this.dataForm.preferences.fields.map((field) => {
          return {
            name: `$${field.name}`
          }
        })
      ]
    },
    rules () {
      return {
        name: [{ required: true, message: fieldRequiredMessage('name') }],
        api_path: [{ required: true, message: fieldRequiredMessage('path') }],
        api_config_name: [{ required: true, message: fieldRequiredMessage('api') }],
        http_method: [{ required: true, message: fieldRequiredMessage('method') }]
      }
    },
    apiRequest () {
      const params = {
        data: this.dataForm,
        include: 'tags'
      }

      if (!this.loadDefault) {
        delete this.dataForm.preferences.default_values_api_path
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
    this.dataForm.preferences.request_type ||= 'rest'

    this.loadDefault = !!this.dataForm.preferences.default_values_api_path || !!this.dataForm.preferences.graphql_query
  },
  methods: {
    changeFormType (value) {
      this.dataForm.preferences.request_type = value
    },
    openApiSettings () {
      this.$Modal.remove()

      this.$Drawer.open(ApiSettings, {}, {
        title: 'API Settings',
        closable: true
      })
    },
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
