<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-8 d-flex align-items-center">
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ form.name || cachedFormName || (isExisting ? '' : i18n['new_form']) }}
      </h1>
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
      :style="{ height: 'calc(var(--vh, 100vh) - 138px)', overflow: 'scroll' }"
      :class="isEditorOpened ? 'col-6 col-lg-9 d-none d-md-block' : 'col-12'"
      class="pt-4 position-relative"
    >
      <Spin
        v-if="isLoading || !isFormDataLoaded"
        fix
      />
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
      style="height: 100%; overflow: scroll"
    >
      <Editor :fields="form.preferences.fields" />
    </div>
  </div>
</template>

<script>
import Editor from '../components/editor'
import CustomFormWrapper from '../components/form_wrapper'
import SaveForm from '../components/save_form'
import { formsStore } from '../scripts/store'
import api from 'api'

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
    CustomFormWrapper
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
        this.form = JSON.parse(JSON.stringify(defaultFormParams))
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
        console.error(error)

        if (error.response.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        }
      }).finally(() => {
        this.isLoading = false
      })
    },
    submit () {
      this.$refs.customFormWrapper.submit()
    },
    onSuccess (form) {
      this.form = form

      this.$Modal.remove()
      this.$Message.info(this.i18n.form_has_been_saved)

      this.$router.push({ name: 'form', params: { id: form.id } })

      this.isEditorOpened = false
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
    }
  }
}
</script>

<style lang="scss">
</style>
