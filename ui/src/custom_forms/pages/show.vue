<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-8">
      <div class="row">
        <div class="col d-flex align-items-center">
          <h1
            class="my-3 overflow-hidden text-truncate"
          >
            {{ form.name || cachedFormName || (isExisting ? '' : i18n['new_form']) }}
          </h1>
        </div>
        <UnsavedChanges
          ref="unsavedChanges"
          :key="form.id || 'new'"
          v-model="form"
          :storage-key="`form:${$route.params.id || 'new'}`"
          class="col d-none d-xl-flex"
        />
      </div>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        v-if="canEdit"
        size="large"
        class="bg-white md-icon-only"
        :icon="isEditorOpened ? 'md-close' : 'md-create'"
        @click="toggleEditor"
      >
        {{ isEditorOpened ? i18n['close_editor'] : i18n['edit'] }}
      </VButton>
      <VButton
        v-if="form.id && $can('create', 'Motor::Form')"
        size="large"
        class="bg-white ms-2 d-none d-sm-block"
        @click="saveAsNew"
      >
        {{ i18n['save_as_new'] }}
      </VButton>
      <VButton
        v-if="form.preferences.fields.length && canEdit"
        size="large"
        class="bg-white ms-2"
        ghost
        type="primary"
        @click="save"
      >
        {{ i18n['save'] }}
      </VButton>
      <VButton
        v-if="form.api_path"
        size="large"
        type="primary"
        class="ms-2 d-none d-md-block"
        @click="submit"
      >
        {{ i18n['submit'] }}
      </VButton>
    </div>
  </div>
  <div
    class="row border-top m-0"
  >
    <div
      :style="{ height: 'calc(var(--vh, 100vh) - 138px)', overflowY: 'auto' }"
      :class="isEditorOpened ? 'col-6 col-lg-9 d-none d-md-block' : 'col-12'"
      class="pt-4 position-relative"
    >
      <Spin
        v-if="isLoading || !isFormDataLoaded"
        fix
      />
      <div
        v-if="isEditorOpened && !form.id && !form.preferences.fields.length && !$refs.editor?.$refs.itemsList.newField"
        class="text-center mt-3"
      >
        <VButton
          size="large"
          icon="md-add"
          @click="toggleNewField"
        >
          {{ i18n.add_field }}
        </VButton>
      </div>
      <Card
        v-show="isFormDataLoaded && form.preferences.fields.length"
        style="max-width: 640px; margin: 0 auto"
        class="mb-3"
      >
        <CustomFormWrapper
          ref="customFormWrapper"
          :form="form"
          @loaded="isFormDataLoaded = true"
        />
      </Card>
    </div>
    <div
      v-if="isEditorOpened"
      class="col-12 col-md-6 col-lg-3 border-left bg-white p-0"
      style="height: 100%; overflowY: auto"
    >
      <Editor
        ref="editor"
        :fields="form.preferences.fields"
      />
    </div>
  </div>
</template>

<script>
import Editor from '../components/editor'
import CustomFormWrapper from '../components/form_wrapper'
import SaveForm from '../components/save_form'
import { formsStore, loadForms } from '../scripts/store'
import api from 'api'
import { modelNameMap } from 'data_resources/scripts/schema'
import singularize from 'inflected/src/singularize'
import { underscore } from 'utils/scripts/string'
import UnsavedChanges from 'utils/components/unsaved_changes'

const columnTypeToFieldMap = {
  string: 'input',
  integer: 'number',
  float: 'number',
  boolean: 'checkbox',
  image: 'file',
  tag: 'input',
  currency: 'number',
  percentage: 'number',
  change: 'number',
  chart: 'number',
  link: 'input'
}

const defaultFormParams = {
  tags: [],
  http_method: 'POST',
  api_path: '',
  preferences: {
    fields: []
  }
}

export default {
  name: 'FromShow',
  components: {
    Editor,
    CustomFormWrapper,
    UnsavedChanges
  },
  data () {
    return {
      isLoading: false,
      isFormDataLoaded: false,
      isEditorOpened: false,
      form: JSON.parse(JSON.stringify(defaultFormParams))
    }
  },
  computed: {
    isExisting () {
      return this.$route.params.id
    },
    resourceName () {
      return this.$route.query?.resource
    },
    resourceAction () {
      return this.$route.query?.action
    },
    resourceModel () {
      return modelNameMap[this.resourceName]
    },
    resourceDefaultFieldParams () {
      return this.resourceModel.columns.map((column) => {
        if (['read_write', 'write_only'].includes(column.access_type)) {
          const field = {
            name: column.name,
            display_name: column.display_name,
            default_value: column.default_value,
            field_type: columnTypeToFieldMap[column.column_type] || column.column_type,
            is_array: column.is_array,
            validators: column.validators.filter((validator) => validator.required)
          }
          if (column.reference) {
            field.reference = { model_name: column.reference.model_name }
          }
          return field
        } else {
          return null
        }
      }).filter(Boolean)
    },
    resourceDefaultFormParams () {
      const fields = ['create', 'update'].includes(this.resourceAction) ? this.resourceDefaultFieldParams : []

      if (this.resourceAction && this.resourceAction !== 'create') {
        fields.unshift({
          name: 'id',
          display_name: singularize(this.resourceModel.display_name),
          default_value: '',
          field_type: 'reference',
          reference: { model_name: this.resourceModel.name },
          validators: [{ required: true }]
        })
      }

      return {
        ...defaultFormParams,
        name: `${this.i18n[this.resourceAction] || this.resourceAction} ${singularize(this.resourceModel.display_name)}`,
        preferences: {
          fields
        }
      }
    },
    canEdit () {
      if (this.isExisting) {
        return this.$can('update', 'Motor::Form', this.form)
      } else {
        return this.$can('create', 'Motor::Form')
      }
    },
    cachedFormName () {
      return formsStore.find((f) => f.id.toString() === this.$route.params?.id)?.name
    }
  },
  watch: {
    '$route' (to, from) {
      if (['form', 'new_form'].includes(to.name)) {
        if (to.params.id !== this.form.id?.toString()) {
          this.onMounted()
        }
      }
    }
  },
  created () {
    this.onMounted()
  },
  methods: {
    onMounted () {
      if (this.$route.params.id) {
        this.loadForm()
      } else {
        this.isEditorOpened = true
        if (this.resourceModel) {
          this.form = JSON.parse(JSON.stringify(this.resourceDefaultFormParams))
        } else {
          this.form = JSON.parse(JSON.stringify(defaultFormParams))
        }
      }
    },
    toggleEditor () {
      this.isEditorOpened = !this.isEditorOpened
    },
    loadForm () {
      this.isLoading = true

      return api.get(`forms/${this.$route.params.id}`, {
        params: {
          include: 'tags'
        }
      }).then((result) => {
        this.form = result.data.data
      }).catch((error) => {
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isLoading = false
      })
    },
    submit () {
      this.$refs.customFormWrapper.submit()
    },
    onSuccess (form) {
      this.$refs.unsavedChanges.resetWithDefaultValue(form)
      this.form = form
      this.$Modal.remove()
      this.$Message.info(this.i18n.form_has_been_saved)

      if (this.resourceModel && this.resourceAction) {
        const action = this.resourceModel.actions.find((action) => action.name === underscore(this.resourceAction)) || { name: underscore(this.resourceAction), display_name: this.resourceAction }

        this.updateResourceAction({ ...action, action_type: 'form', preferences: { form_id: this.form.id } }, this.resourceName)
      }

      loadForms()
      this.$router.push({ name: 'form', params: { id: form.id } })

      this.isEditorOpened = false
    },
    updateResourceAction (action, resourceName) {
      return api.post('resources', {
        data: {
          name: this.resourceModel.name,
          preferences: {
            actions: [action]
          }
        }
      }).then((result) => {
        const resourceActions = modelNameMap[resourceName].actions
        const existingAction = resourceActions.find((a) => a.name === action.name)

        existingAction ? Object.assign(existingAction, action) : resourceActions.push(action)
      }).catch((error) => {
        console.error(error)
      })
    },
    saveAsNew () {
      this.$Modal.open(SaveForm, {
        form: {
          ...this.form,
          id: null,
          tags: this.form.tags.map((tag) => tag.name)
        },
        action: 'new',
        onSuccess: (form) => {
          this.onSuccess(form)
        }
      }, {
        title: this.i18n.save_form,
        closable: true
      })
    },
    save () {
      this.$Modal.open(SaveForm, {
        form: {
          ...this.form,
          tags: this.form.tags.map((tag) => tag.name)
        },
        onSuccess: (form) => {
          this.onSuccess(form)
        }
      }, {
        title: this.i18n.save_form,
        closable: true
      })
    },
    toggleNewField () {
      this.$refs.editor.toggleNewField()
    }
  }
}
</script>

<style lang="scss">
</style>
