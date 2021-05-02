<template>
  <div
    class="bg-white p-2"
    style="height: 100%"
  >
    <div style="min-height: calc(var(--vh, 100vh) - 195px); overflow-y: scroll">
      <VueDraggableNext
        :list="form.preferences.fields"
        handle=".handle"
      >
        <FieldItem
          v-for="field in form.preferences.fields"
          :key="field.name"
          :field="field"
          class="mb-2"
          @remove="removeField"
          @replace="replaceField"
        />
      </VueDraggableNext>
      <Card v-if="newField">
        <FieldForm
          :field="newField"
          ok-text="Add"
          @submit="addField"
          @cancel="newField = null"
        />
      </Card>
    </div>
    <div class="footer">
      <VButton
        long
        type="default"
        :icon="newField ? 'md-close' : 'md-add'"
        @click="toggleNewField"
      >
        {{ newField ? 'Cancel' : 'Add Field' }}
      </VButton>
    </div>
  </div>
</template>

<script>
import FieldForm from './field_form'
import FieldItem from './field_item'

const defaultFieldParams = {
  display_name: '',
  name: '',
  field_type: 'input',
  default_value: '',
  validators: []
}

export default {
  name: 'FormEditor',
  components: {
    FieldForm,
    FieldItem
  },
  props: {
    form: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      newField: null,
      dataForm: JSON.parse(JSON.stringify(this.form))
    }
  },
  computed: {
    rules () {
      return {
        name: [{ required: true }],
        api_path: [{ required: true }],
        http_method: [{ required: true }]
      }
    }
  },
  watch: {
    form (value) {
      this.dataForm = JSON.parse(JSON.stringify(value))
    }
  },
  mounted () {
    if (!this.form.preferences.fields.length) {
      this.newField = { ...defaultFieldParams }
    }
  },
  methods: {
    toggleNewField () {
      if (this.newField) {
        this.newField = null
      } else {
        this.newField = JSON.parse(JSON.stringify(defaultFieldParams))
      }
    },
    addField (field) {
      this.form.preferences.fields.push(field)

      this.newField = null
    },
    removeField (field) {
      const index = this.form.preferences.fields.indexOf(field)

      this.form.preferences.fields.splice(index, 1)
    },
    replaceField ([oldField, newField]) {
      const index = this.form.preferences.fields.indexOf(oldField)

      this.form.preferences.fields.splice(index, 1, newField)
    }
  }
}
</script>

<style lang="scss" scoped>
.footer {
  width: 100%;
  position: sticky;
  bottom: 0;
  left: 0;
  border-top: 1px solid #e8e8e8;
  padding-top: 10px;
  text-align: right;
  background: #fff;
}
</style>
