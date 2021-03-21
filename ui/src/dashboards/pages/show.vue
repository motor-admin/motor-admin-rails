<template>
  <div
    class="row mx-2"
    style="min-height: 74px"
  >
    <div class="col-8">
      <h1
        class="my-3"
      >
        {{ board.title || (isExisting ? '' : 'New dashboard') }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        size="large"
        class="bg-white me-2"
        :icon="isEditorOpened ? 'md-close' : 'md-create'"
        @click="toggleEditor"
      >
        {{ isEditorOpened ? 'Close editor' : 'Edit' }}
      </VButton>
      <VButton
        size="large"
        class="bg-white me-2"
        @click="save"
      >
        Save
      </VButton>
      <VButton
        size="large"
        type="primary"
      >
        <Icon type="md-play" />
      </VButton>
    </div>
  </div>
  <div
    :style="{ height: 'calc(100vh - 134px)', margin: '0 2px' }"
    class="row border-top"
  >
    <div
      :class="isEditorOpened ? 'col-6 col-lg-9 d-none d-md-block' : 'col-12'"
      style="height: 100%; overflow: scroll"
    >
      <DashboardLayout :layout="board.preferences.layout" />
    </div>
    <div
      v-if="isEditorOpened"
      class="col-12 col-md-6 col-lg-3 border-left bg-white p-0"
      style="height: 100%; overflow: scroll"
    >
      <Editor
        :layout="board.preferences.layout"
      />
    </div>
  </div>
</template>

<script>
import Editor from '../components/editor'
import DashboardLayout from '../components/layout'
import DashboardForm from '../components/form'
import api from 'api'

export default {
  name: 'DashboardsNew',
  components: {
    Editor,
    DashboardLayout
  },
  data () {
    return {
      isEditorOpened: false,
      board: {
        preferences: {
          layout: []
        }
      }
    }
  },
  computed: {
    isExisting () {
      return this.$route.params.id
    }
  },
  watch: {
    '$route' (to, from) {
      if (!to.params.id && to.params.id !== from.params.id) {
        this.board = { preferences: { layout: [] } }
      }
    }
  },
  mounted () {
    if (this.$route.params.id) {
      this.loadDashboard()
    } else {
      this.isEditorOpened = true
    }
  },
  methods: {
    toggleEditor () {
      this.isEditorOpened = !this.isEditorOpened
    },
    loadDashboard () {
      return api.get(`api/dashboards/${this.$route.params.id}`).then((result) => {
        this.board = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    },
    save () {
      this.$Modal.open(DashboardForm, {
        board: {
          id: this.board.id,
          title: this.board.title,
          description: this.board.description,
          tags: this.board.tags,
          preferences: this.board.preferences
        },
        onSuccess: (result) => {
          this.board = result

          this.$Modal.remove()
          this.$Message.success('Dashboard has been saved!')

          this.$router.push({ name: 'dashboard', params: { id: result.id } })

          this.isEditorOpened = false
        }
      }, {
        title: 'Save dashboard',
        closable: true
      })
    }
  }
}
</script>

<style lang="scss">
</style>
