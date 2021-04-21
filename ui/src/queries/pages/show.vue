<template>
  <div
    class="row mx-2"
    style="min-height: 74px"
  >
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
        ghost
        type="primary"
        class="bg-white me-2"
        @click="save"
      >
        Save
      </VButton>
      <VButton
        size="large"
        type="primary"
        :loading="isLoading"
        icon="md-play"
        @click="runQuery"
      />
    </div>
  </div>
  <div
    :style="{ height: isVariablesForm ? 'calc(100vh - 222px)' : 'calc(100vh - 134px)' }"
    class="row border-top m-0"
  >
    <div
      v-if="isSettingsOpened"
      class="p-0 col-12 col-md-6 col-lg-3 border-right"
    >
      <Settings
        :preferences="dataQuery.preferences"
        :data="data"
        :columns="columns"
        style="height: 100%"
        @close="toggleSettings"
      />
    </div>
    <div
      class="p-0"
      :class="isSettingsOpened ? 'col-6 col-lg-9 d-none d-md-block' : 'col-12'"
    >
      <div
        v-if="isVariablesForm"
        class="pb-3 pt-1 px-3 border-bottom"
      >
        <VariablesForm
          v-model:data="variablesData"
          :variables="dataQuery.preferences.variables"
          @submit="runQuery"
        />
      </div>

      <Split
        v-model="split"
        mode="vertical"
      >
        <template #top>
          <SqlEditor
            v-if="isEdit"
            v-model="dataQuery.sql_body"
            @run="runQuery"
          />
        </template>
        <template #bottom>
          <Spin
            v-if="isLoading || isLoadingQuery"
            fix
          />
          <QueryResult
            :data="data"
            :errors="errors"
            :title="query.name"
            :columns="columns"
            :query-id="query.id"
            :with-alert="!!query.id"
            :preferences="dataQuery.preferences"
            @settings="toggleSettings"
          />
        </template>
      </Split>
    </div>
  </div>
</template>

<script>
import SqlEditor from '../components/sql_editor'
import QueryResult from '../components/result'
import QueryForm from '../components/form'
import Settings from '../components/settings'
import throttle from 'view3/src/utils/throttle'
import VariablesForm from '../components/variables_form'
import { titleize } from 'utils/scripts/string'

import api from 'api'

const defaultQueryParams = {
  name: '',
  sql_body: '',
  tags: [],
  preferences: {}
}

export default {
  name: 'QueriesShow',
  components: {
    SqlEditor,
    QueryResult,
    Settings,
    VariablesForm
  },
  data () {
    return {
      split: 0,
      isLoading: false,
      isLoadingQuery: false,
      query: { ...defaultQueryParams },
      dataQuery: {
        sql_body: '',
        preferences: {}
      },
      variablesData: {},
      isSettingsOpened: false,
      errors: [],
      columns: [],
      data: []
    }
  },
  computed: {
    defaultSplit () {
      return 0.35
    },
    locationHashParams () {
      return JSON.parse(window.atob(location.hash.replace(/^#/, '')) || 'null')
    },
    isEdit () {
      return this.split !== 0 || this.isSettingsOpened || this.isEdited
    },
    isEdited () {
      return JSON.stringify(this.dataQuery) !== JSON.stringify({ sql_body: this.query.sql_body, preferences: this.query.preferences })
    },
    isExisting () {
      return this.$route.params.id
    },
    canSave () {
      return this.dataQuery.sql_body && this.isEdit
    },
    canSaveNew () {
      return this.query.id && this.isEdited
    },
    isVariablesForm () {
      return !!this.dataQuery.preferences.variables?.length
    }
  },
  watch: {
    '$route' (to, from) {
      if (to.name === 'query') {
        const isNewQuery = to.params.id !== this.query.id?.toString()

        if (isNewQuery) {
          this.onMounted()
        }
      }

      if (to.name === 'new_query') {
        const isNewQuery = to.params.id !== this.query.id?.toString()

        if (isNewQuery) {
          this.dataQuery = { sql_body: '', preferences: {} }
          this.query = { ...defaultQueryParams }

          this.onMounted()
        }
      }
    },
    'dataQuery.sql_body': throttle(async function (value) {
      this.dataQuery.preferences.variables = this.extractVariablesFromSql(value)
    }, 500),
    dataQuery: {
      deep: true,
      handler: throttle(async function (value) {
        const stringValue = JSON.stringify(value)

        if (stringValue !== JSON.stringify({ sql_body: this.query.sql_body, preferences: this.query.preferences })) {
          location.replace('#' + window.btoa(stringValue))
        } else {
          location.hash = ''
        }
      }, 0.5 * 1000)
    }
  },
  created () {
    this.dataQuery = JSON.parse(JSON.stringify(this.locationHashParams)) || { sql_body: '', preferences: {} }

    this.onMounted()
  },
  methods: {
    assignVariablesData () {
      this.variablesData = (this.dataQuery.preferences.variables || []).reduce((acc, variable) => {
        acc[variable.name] = variable.default_value

        return acc
      }, {})
    },
    toggleSettings () {
      this.isSettingsOpened = !this.isSettingsOpened
    },
    onMounted () {
      if (this.dataQuery.sql_body) {
        this.openEditor()
      }

      if (this.$route.params.id) {
        this.loadQuery()
      } else {
        this.query = JSON.parse(JSON.stringify(defaultQueryParams))
        this.data = []
        this.columns = []
        this.openEditor()

        if (this.dataQuery.sql_body) {
          this.runQuery()
        }
      }
    },
    openEditor () {
      this.split = 0.35
    },
    loadQuery () {
      this.isLoadingQuery = true

      api.get(`queries/${this.$route.params.id}`, {
        params: {
          include: 'tags'
        }
      }).then((result) => {
        this.query = {
          ...result.data.data,
          tags: result.data.data.tags.map((t) => t.name)
        }

        if (!this.locationHashParams) {
          Object.assign(this.dataQuery, JSON.parse(JSON.stringify({
            sql_body: this.query.sql_body,
            preferences: this.query.preferences
          })))
        }

        this.assignVariablesData()
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoadingQuery = false
      })

      if (this.locationHashParams?.sql_body) {
        this.runQuery()
      } else {
        this.isLoading = true

        api.get(`run_queries/${this.$route.params.id}`, {
        }).then((result) => {
          this.errors = []
          this.data = result.data.data
          this.columns = result.data.meta.columns
        }).catch((error) => {
          this.errors = error.response.data?.errors
        }).finally(() => {
          this.isLoading = false
        })
      }
    },
    extractVariablesFromSql (sql) {
      if (sql) {
        const mached = sql.match(/{{\w+}}/g)
        const variables = mached?.map((matched) => matched.replace(/[{}]/g, '')) || []

        return variables.map((variableName) => {
          const defaultValue = this.dataQuery.preferences.variables?.find((variable) => {
            return variable.name === variableName
          })?.default_value

          return { name: variableName, display_name: titleize(variableName), default_value: defaultValue || '' }
        })
      } else {
        return []
      }
    },
    save () {
      this.$Modal.open(QueryForm, {
        query: {
          ...this.query,
          sql_body: this.dataQuery.sql_body,
          preferences: this.dataQuery.preferences
        },
        action: this.query.id ? 'edit' : 'new',
        onSuccess: (result) => {
          this.query = result
          this.$Modal.remove()
          this.$Message.info('Query has been saved!')

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
          preferences: this.dataQuery.preferences,
          sql_body: this.dataQuery.sql_body
        },
        action: 'new',
        onSuccess: (result) => {
          this.query = result
          this.$Modal.remove()
          this.$Message.info('Query has been saved!')

          this.$router.push({ name: 'query', params: { id: result.id } })
        }
      }, {
        title: 'Save query',
        closable: true
      })
    },
    runQuery () {
      this.isLoading = true

      api.post('run_queries', {
        data: this.dataQuery,
        variables: this.variablesData
      }).then((result) => {
        this.errors = []
        this.data = result.data.data
        this.columns = result.data.meta.columns
      }).catch((error) => {
        this.errors = error.response.data?.errors
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>

<style lang="scss">
</style>
