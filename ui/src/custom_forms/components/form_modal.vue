<template>
  <CustomForm
    v-if="form"
    :form="form"
    :data="data"
    @success="$emit('success', $event)"
    @error="$emit('error', $event)"
    @submit="$emit('submit', $event)"
  />
  <Spin
    v-else
    fix
  />
</template>

<script>
import CustomForm from './custom_form'
import api from 'api'

export default {
  name: 'CustomFormModal',
  components: {
    CustomForm
  },
  props: {
    data: {
      type: Object,
      required: true
    },
    formId: {
      type: Number,
      required: true
    }
  },
  emits: ['submit', 'success', 'error'],
  data () {
    return {
      form: null,
      isLoading: true
    }
  },
  mounted () {
    this.loadForm()
  },
  methods: {
    loadForm () {
      return api.get(`forms/${this.formId}`, {
      }).then((result) => {
        this.form = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
