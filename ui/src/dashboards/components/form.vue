<template>
  <VForm
    ref="form"
    :model="dataBoard"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      :label="i18n['title']"
      prop="title"
    >
      <VInput
        v-model="dataBoard.title"
        size="large"
        :autofocus="true"
        :placeholder="i18n['dashboard_title']"
      />
    </FormItem>
    <FormItem
      :label="i18n['description']"
      prop="description"
    >
      <VInput
        v-model="dataBoard.description"
        type="textarea"
        :placeholder="i18n['describe_your_dashboard_optional']"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      :label="i18n['tags']"
      prop="tags"
    >
      <TagsSelect
        v-model="dataBoard.tags"
        :placeholder="i18n['select_dashboard_tags']"
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
import { fieldRequiredMessage } from 'utils/scripts/i18n'

export default {
  name: 'DashboardForm',
  components: {
    TagsSelect
  },
  props: {
    board: {
      type: Object,
      required: true
    }
  },
  emits: ['success'],
  data () {
    return {
      dataBoard: {}
    }
  },
  computed: {
    rules () {
      return {
        title: [{ required: true, message: fieldRequiredMessage('title') }]
      }
    },
    apiRequest () {
      const params = {
        data: this.dataBoard,
        include: 'tags,queries',
        fields: {
          queries: 'id,name,preferences'
        }
      }

      if (this.board.id) {
        return api.put(`dashboards/${this.dataBoard.id}`, params)
      } else {
        return api.post('dashboards', params)
      }
    }
  },
  created () {
    this.dataBoard = JSON.parse(JSON.stringify(this.board))
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
          })
        }
      })
    }
  }
}
</script>
