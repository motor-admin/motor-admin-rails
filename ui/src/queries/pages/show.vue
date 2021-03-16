<template>
  <div class="row mx-2">
    <div class="col-8">
      <h1
        class="my-3"
      >
        {{ query.name || (isExisting ? '' : 'New query') }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        v-if="!isEdit"
        size="large"
        class="bg-white me-2"
        icon="md-create"
        @click="openEditor"
      >
        Edit
      </VButton>
      <VButton
        v-if="canSaveNew"
        size="large"
        class="bg-white me-2"
        @click="saveAsNew"
      >
        Save as new
      </VButton>
      <VButton
        v-if="canSave"
        size="large"
        class="bg-white me-2"
        @click="save"
      >
        Save
      </VButton>
      <VButton
        size="large"
        type="primary"
        @click="runQuery"
      >
        <Icon type="md-play" />
      </VButton>
    </div>
  </div>
  <div
    :style="{ height: 'calc(100vh - 134px)' }"
    class="border-top"
  >
    <Split
      v-model="split"
      mode="vertical"
    >
      <template #top>
        <SqlEditor
          v-if="isEdit"
          v-model="sqlBody"
          @run="runQuery"
        />
      </template>
      <template #bottom>
        <Spin
          v-if="isLoading"
          fix
        />
        <QueryTable
          :data="data"
          :columns="columns"
        />
      </template>
    </Split>
  </div>
</template>

<script>
import SqlEditor from '../components/sql_editor'
import QueryTable from '../components/table'
import QueryForm from '../components/form'
import throttle from 'view3/src/utils/throttle'

import api from 'api'

const defaultQueryParams = {
  name: '',
  sql_body: '',
  tags: [],
  preferences: { variables: [] }
}

export default {
  name: 'QueriesShow',
  components: {
    SqlEditor,
    QueryTable
  },
  data () {
    return {
      split: 0,
      isLoading: false,
      query: { ...defaultQueryParams },
      sqlBody: '',
      columns: [],
      data: []
    }
  },
  computed: {
    defaultSplit () {
      return 0.35
    },
    locationHashParams () {
      return JSON.parse(window.atob(location.hash.replace(/^#/, '')) || '{}')
    },
    isEdit () {
      return this.split !== 0
    },
    isExisting () {
      return this.$route.params.id
    },
    canSave () {
      return this.sqlBody && this.isEdit
    },
    canSaveNew () {
      return this.query.id && this.sqlBody !== this.query.sql_body
    }
  },
  watch: {
    '$route' (to, from) {
      const isNewQuery = to.params.id !== this.query.id?.toString()

      if (isNewQuery) {
        this.onMounted()
      }
    },
    sqlBody: throttle(async function (value) {
      if (this.query.sql_body !== this.sqlBody) {
        location.hash = window.btoa(JSON.stringify({ sqlBody: value }))
      } else {
        location.hash = ''
      }
    }, 1.5 * 1000)
  },
  mounted () {
    this.onMounted()
  },
  methods: {
    onMounted () {
      this.sqlBody = this.locationHashParams.sqlBody || ''

      if (this.sqlBody) {
        this.openEditor()
      }

      if (this.$route.params.id) {
        this.loadQuery()
      } else {
        this.query = JSON.parse(JSON.stringify(defaultQueryParams))
        this.data = []
        this.columns = []
        this.openEditor()

        if (this.sqlBody) {
          this.runQuery()
        }
      }
    },
    openEditor () {
      this.split = 0.35
    },
    loadQuery () {
      this.isLoading = true

      api.get(`api/queries/${this.$route.params.id}`, {
        params: {
          include: 'tags'
        }
      }).then((result) => {
        this.query = {
          ...result.data.data,
          tags: result.data.data.tags.map((t) => t.name)
        }

        this.sqlBody ||= this.query.sql_body
      }).catch((error) => {
        console.error(error)
      })

      if (this.locationHashParams.sqlBody) {
        this.runQuery()
      } else {
        api.get(`api/run_queries/${this.$route.params.id}`, {
        }).then((result) => {
          this.data = result.data.data
          this.columns = result.data.meta.columns
        }).finally(() => {
          this.isLoading = false
        })
      }
    },
    save () {
      this.$Modal.open(QueryForm, {
        query: {
          ...this.query,
          sql_body: this.sqlBody
        },
        action: this.query.id ? 'edit' : 'new',
        onSuccess: (result) => {
          this.query = result
          this.$Modal.remove()
          this.$Message.success('Query has been saved!')

          this.$router.push({ name: 'query', params: { id: result.id } })
        }
      }, {
        title: 'Save query',
        closable: true
      })
    },
    saveAsNew () {
      this.$Modal.open(QueryForm, {
        query: {
          name: this.query.name,
          description: this.query.description,
          tags: this.query.tags,
          sql_body: this.sqlBody
        },
        action: 'new',
        onSuccess: (result) => {
          this.query = result
          this.$Modal.remove()
          this.$Message.success('Query has been saved!')

          this.$router.push({ name: 'query', params: { id: result.id } })
        }
      }, {
        title: 'Save query',
        closable: true
      })
    },
    runQuery () {
      this.isLoading = true

      api.post('api/run_queries', {
        data: {
          sql_body: this.sqlBody,
          preferences: this.query.preferences
        }
      }).then((result) => {
        this.data = result.data.data
        this.columns = result.data.meta.columns
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>

<style lang="scss">
</style>
