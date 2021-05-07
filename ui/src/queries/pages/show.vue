<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-8 d-flex align-items-center">
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ query.name || (isExisting ? '' : 'New query') }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        v-if="vSplit !== 0 && dataQuery.preferences.visualization === 'markdown'"
        size="large"
        class="me-2 md-icon-only"
        :icon="isMarkdownEditor ? 'md-code-working' : 'logo-markdown'"
        @click="isMarkdownEditor = !isMarkdownEditor"
      >
        {{ isMarkdownEditor ? 'Edit SQL' : 'Edit Markdown' }}
      </VButton>
      <VButton
        v-if="vSplit === 0"
        size="large"
        class="bg-white me-2 md-icon-only"
        icon="md-create"
        @click="openEditor"
      >
        Edit
      </VButton>
      <VButton
        v-if="canSaveNew"
        size="large"
        class="bg-white me-2 d-none d-md-block"
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
    :style="{ height: isVariablesForm ? 'calc(var(--vh, 100vh) - 217px)' : 'calc(var(--vh, 100vh) - 134px)' }"
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
        class="pb-3 pt-1 px-3 px-md-4 border-bottom"
      >
        <VariablesForm
          v-model:data="variablesData"
          :variables="dataQuery.preferences.variables"
          @submit="runQuery"
        />
      </div>

      <Split
        v-model="vSplit"
        mode="vertical"
        :style="{ height: isSettingsOpened && isVariablesForm ? 'calc(100% - 82px)' : '100%' }"
      >
        <template #top>
          <template v-if="vSplit > 0">
            <CodeEditor
              v-if="dataQuery.preferences.visualization === 'markdown' && isMarkdownEditor"
              v-model="dataQuery.preferences.visualization_options.markdown"
              language="markdown"
              @run="runQuery"
            />
            <CodeEditor
              v-else
              v-model="dataQuery.sql_body"
              language="pgsql"
              @run="runQuery"
            />
          </template>
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
            :show-markdown-table="!widthLessThan('md') && isEdit"
            :preferences="dataQuery.preferences"
            @settings="toggleSettings"
          />
        </template>
      </Split>
    </div>
  </div>
</template>

<script>
import CodeEditor from '../components/code_editor'
import QueryResult from '../components/result'
import QueryForm from '../components/form'
import Settings from '../components/settings'
import throttle from 'view3/src/utils/throttle'
import VariablesForm from '../components/variables_form'
import { titleize } from 'utils/scripts/string'
import singularize from 'inflected/src/singularize'
import { widthLessThan } from 'utils/scripts/dimensions'
import { modelNameMap } from 'data_resources/scripts/schema'

import api from 'api'

const defaultQueryParams = {
  name: '',
  sql_body: '',
  tags: [],
  preferences: {
    visualization: 'table',
    visualization_options: {},
    variables: []
  }
}

export default {
  name: 'QueriesShow',
  components: {
    CodeEditor,
    QueryResult,
    Settings,
    VariablesForm
  },
  data () {
    return {
      vSplit: 0,
      isLoading: false,
      isLoadingQuery: false,
      isMarkdownEditor: false,
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
      return this.vSplit !== 0 || this.isSettingsOpened || this.isEdited
    },
    isEdited () {
      return JSON.stringify(this.dataQuery.preferences) !== JSON.stringify(this.query.preferences) || this.dataQuery.sql_body !== this.query.sql_body
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
    },
    queryDataLocationHashString () {
      return '#' + window.btoa(this.dataQueryString)
    },
    queryString () {
      return JSON.stringify({ sql_body: this.query.sql_body, preferences: this.query.preferences })
    },
    dataQueryString () {
      return JSON.stringify({ sql_body: this.dataQuery.sql_body, preferences: this.dataQuery.preferences })
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
          this.dataQuery = { ...defaultQueryParams }
          this.query = { ...defaultQueryParams }

          this.onMounted()
        } else if (to.hash !== this.queryDataLocationHashString) {
          this.dataQuery = JSON.parse(JSON.stringify(JSON.parse(window.atob(location.hash.replace(/^#/, '')) || 'null'))) || { ...defaultQueryParams }
          this.dataQuery.preferences = { ...defaultQueryParams.preferences, ...this.dataQuery.preferences }
        }
      }
    },
    'dataQuery.sql_body': throttle(async function (value) {
      this.assignVariablesFromSql(value)
    }, 500),
    'dataQuery.preferences.visualization' (value) {
      if (value === 'markdown') {
        this.isMarkdownEditor = true
      }
    },
    dataQuery: {
      deep: true,
      handler: throttle(async function (value) {
        if (this.dataQueryString !== this.queryString) {
          location.replace(this.queryDataLocationHashString)
        } else {
          location.hash = ''
        }
      }, 0.5 * 1000)
    }
  },
  created () {
    this.assignDataFromLocationHash()
    this.onMounted()
  },
  methods: {
    widthLessThan,
    assignDataFromLocationHash () {
      this.dataQuery = JSON.parse(JSON.stringify(this.locationHashParams)) || { ...defaultQueryParams }
      this.dataQuery.preferences = { ...defaultQueryParams.preferences, ...this.dataQuery.preferences }
    },
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
          this.assignVariablesData()
          this.runQuery()
        }
      }
    },
    openEditor () {
      this.vSplit = 0.35
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
          preferences: {
            ...defaultQueryParams.preferences,
            ...result.data.data.preferences
          },
          tags: result.data.data.tags.map((t) => t.name)
        }

        if (!this.locationHashParams) {
          Object.assign(this.dataQuery, JSON.parse(JSON.stringify({
            sql_body: this.query.sql_body,
            preferences: {
              ...defaultQueryParams.preferences,
              ...this.query.preferences
            }
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
    assignVariablesFromSql (sql) {
      if (sql) {
        const variablesCaptures = sql.match(/{{[#/^]?\s*(\w+)\s*}}/g)

        if (variablesCaptures) {
          const variables =
            variablesCaptures.map(e => e.replace(/\W/g, '')).filter((el, i, a) => i === a.indexOf(el))

          this.dataQuery.preferences.variables.forEach((variable, index, arr) => {
            const variableIndex = variables.indexOf(variable.name)

            if (variableIndex === -1) {
              arr.splice(index, 1)
            } else {
              variables.splice(variableIndex, 1)
            }
          })

          variables.forEach((variableName) => {
            const variable = {
              name: variableName,
              display_name: titleize(variableName),
              variable_type: 'text'
            }

            const model = modelNameMap[variableName.replace(/_id$/, '')]

            if (model) {
              Object.assign(variable, {
                display_name: singularize(model.display_name),
                reference_resource: model.name,
                variable_type: 'reference'
              })
            }

            this.dataQuery.preferences.variables.push(variable)
          })
        } else {
          this.dataQuery.preferences.variables = []
        }
      } else {
        this.dataQuery.preferences.variables = []
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
      if (!this.isLoading) {
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
}
</script>

<style lang="scss">
</style>
