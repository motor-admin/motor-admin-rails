<template>
  <VForm
    ref="form"
    :model="dataBoard"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      label="Title"
      prop="title"
    >
      <VInput
        v-model="dataBoard.title"
        size="large"
        placeholder="Dashboard title"
      />
    </FormItem>
    <FormItem
      label="Description"
      prop="description"
    >
      <VInput
        v-model="dataBoard.description"
        type="textarea"
        placeholder="Describe your dashboard (optional)"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      label="Tags"
      prop="tags"
    >
      <TagsSelect
        v-model="dataBoard.tags"
        placeholder="Select dashboard tags"
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
        title: [{ required: true }]
      }
    },
    apiRequest () {
      const params = {
        data: this.dataBoard
      }

      if (this.board.id) {
        return api.put(`api/dashboards/${this.dataBoard.id}`, params)
      } else {
        return api.post('api/dashboards', params)
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
            console.error(error)
          })
        }
      })
    }
  }
}
</script>
