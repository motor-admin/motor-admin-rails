<template>
  <VForm
    ref="form"
    :model="dataQuery"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      :label="i18n['name']"
      prop="name"
    >
      <VInput
        v-model="dataQuery.name"
        size="large"
        :autofocus="true"
        :placeholder="i18n['query_name']"
      />
    </FormItem>
    <FormItem
      :label="i18n['description']"
      prop="description"
    >
      <VInput
        v-model="dataQuery.description"
        type="textarea"
        :placeholder="i18n['describe_your_query_optional']"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      :label="i18n['tags']"
      prop="tags"
    >
      <TagsSelect
        v-model="dataQuery.tags"
        :placeholder="i18n['select_query_tags']"
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
  name: 'QueryForm',
  components: {
    TagsSelect
  },
  props: {
    query: {
      type: Object,
      required: true
    },
    action: {
      type: String,
      required: false,
      default: 'new',
      validator (value) {
        return ['edit', 'new'].includes(value)
      }
    }
  },
  emits: ['success'],
  data () {
    return {
      dataQuery: {}
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true, message: fieldRequiredMessage('name') }]
      }
    },
    apiRequest () {
      const params = {
        data: this.dataQuery,
        include: 'tags'
      }

      if (this.dataQuery.preferences.query_type === 'api') {
        params.data.sql_body = ''
      }

      if (this.dataQuery.preferences.query_type === 'sql') {
        delete params.data.preferences.api_path
      }

      if (this.action === 'edit') {
        return api.put(`queries/${this.dataQuery.id}`, params)
      } else {
        return api.post('queries', params)
      }
    }
  },
  created () {
    this.dataQuery = JSON.parse(JSON.stringify(this.query))

    if (this.action === 'new') {
      delete this.dataQuery.id
    }
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.apiRequest.then((result) => {
            this.$emit('success', {
              ...result.data.data
            })
          }).catch((error) => {
            if (error.response.data.errors?.length) {
              this.$refs.form.setErrors(error.response.data.errors)
            }

            console.error(error)
          })
        }
      })
    }
  }
}
</script>
