<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-8 d-flex align-items-center">
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ form.name || cachedFormName || (isExisting ? '' : 'New form') }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        size="large"
        class="bg-white md-icon-only"
        :icon="isEditorOpened ? 'md-close' : 'md-create'"
        @click="toggleEditor"
      >
        {{ isEditorOpened ? 'Close editor' : 'Edit' }}
      </VButton>
      <VButton
        v-if="form.preferences.fields.length"
        size="large"
        class="bg-white ms-2"
        ghost
        type="primary"
        @click="save"
      >
        Save
      </VButton>
      <VButton
        v-if="form.api_path"
        size="large"
        type="primary"
        class="ms-2 d-none d-md-block"
        @click="submit"
      >
        Submit
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
        v-if="isLoading"
        fix
      />
      <Card
        v-if="form.preferences.fields.length"
        style="max-width: 640px; margin: 0 auto"
        class="mb-3"
      >
        <CustomForm
          ref="customForm"
          :form="form"
        />
      </Card>
    </div>
    <div
      v-if="isEditorOpened"
      class="col-12 col-md-6 col-lg-3 border-left bg-white p-0"
      style="height: 100%; overflow: scroll"
    >
      <Editor :form="form" />
    </div>
  </div>
</template>

<script>
import Editor from '../components/editor'
import CustomForm from '../components/custom_form'
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
    CustomForm
  },
  data () {
    return {
      isLoading: false,
      isEditorOpened: false,
      form: JSON.parse(JSON.stringify(defaultFormParams))
    }
  },
  computed: {
    isExisting () {
      return this.$route.params.id
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
      }).finally(() => {
        this.isLoading = false
      })
    },
    submit () {
      this.$refs.customForm.handleSubmit()
    },
    save () {
      this.$Modal.open(SaveForm, {
        form: {
          ...this.form,
          tags: this.form.tags.map((tag) => tag.name)
        },
        onSuccess: (form) => {
          Object.assign(this.form, {
            id: form.id,
            api_path: form.api_path,
            http_method: form.http_method,
            name: form.name,
            description: form.description,
            tags: form.tags
          })

          this.$Modal.remove()
          this.$Message.info('Form has been saved!')

          this.$router.push({ name: 'form', params: { id: form.id } })

          this.isEditorOpened = false
        }
      }, {
        title: 'Save form',
        closable: true
      })
    }
  }
}
</script>

<style lang="scss">
</style>
