<template>
  <VForm
    ref="form"
    :model="dataQuery"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      label="Name"
      prop="name"
    >
      <VInput
        v-model="dataQuery.name"
        size="large"
        placeholder="Query name"
      />
    </FormItem>
    <FormItem
      label="Description"
      prop="description"
    >
      <VInput
        v-model="dataQuery.description"
        type="textarea"
        placeholder="Describe your query (optional)"

        :autosize="{ minRows: 3, maxRows: 7 }"
      />
    </FormItem>
    <FormItem
      label="Tags"
      prop="tags"
    >
      <TagsSelect
        v-model="dataQuery.tags"
        placeholder="Select query tags"
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
        name: [{ required: true }]
      }
    },
    apiRequest () {
      const params = {
        data: this.dataQuery,
        include: 'tags'
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
              ...result.data.data,
              tags: result.data.data.tags.map((t) => t.name)
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
