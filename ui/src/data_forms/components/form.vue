<template>
  <VForm
    ref="form"
    :model="data"
    :rules="rules"
    label-position="top"
  >
    <FormItem
      v-for="column in columns"
      :key="column.name"
      :label="column.display_name"
    >
      <FormInput
        v-model="formData[column.name]"
        :column="column"
      />
    </FormItem>
  </VForm>
</template>

<script>
import FormInput from './input'

export default {
  name: 'DataForm',
  components: {
    FormInput
  },
  props: {
    data: {
      type: Object,
      required: false,
      default () {
        return {}
      }
    },
    columns: {
      type: Array,
      required: true
    }
  },
  emits: ['submit'],
  data () {
    return {
      formData: {}
    }
  },
  computed: {
    rules () {
      return []
    }
  },
  watch: {
    data (value) {
      this.formData = JSON.parse(JSON.stringify(value))
    }
  },
  mounted () {
    this.formData = JSON.parse(JSON.stringify(this.data))
  },
  methods: {
    handleSubmit () {
      this.$emit('submit', this.formData)
    }
  }
}
</script>
