<template>
  <div
    class="bg-white p-2"
    style="height: calc(var(--vh, 100vh) - 135px)"
  >
    <div>
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
      <Card
        v-if="newField"
        class="mb-2"
      >
        <FieldForm
          :field="newField"
          ok-text="Add"
          @submit="addField"
          @cancel="newField = null"
        />
      </Card>
    </div>
    <div
      v-if="!newField"
      class="footer"
    >
      <VButton
        long
        type="default"
        icon="md-add"
        @click="toggleNewField"
      >
        Add Field
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
  padding-bottom: 10px;
  text-align: right;
  background: #fff;
}
</style>
