<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div class="col-8 d-flex align-items-center">
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ query.name || cachedQueryName || (isExisting ? '' : i18n['new_query']) }}
      </h1>
    </div>
    <div class="col-4 d-flex align-items-center justify-content-end">
      <VButton
        v-if="query.id && query.updated_at !== query.created_at && $can('edit', 'Motor::Query', query)"
        size="large"
        class="bg-white me-2 md-icon-only d-none d-sm-block"
        icon="md-time"
        @click="openRevisionsModal"
      >
        {{ i18n['revisions'] }}
      </VButton>
      <VButton
        v-if="vSplit !== 0 && dataQuery.preferences.visualization === 'markdown'"
        size="large"
        class="me-2 md-icon-only"
        :icon="isMarkdownEditor ? 'md-code-working' : 'logo-markdown'"
        @click="isMarkdownEditor = !isMarkdownEditor"
      >
        {{ isMarkdownEditor ? i18n['edit_sql'] : i18n['edit_markdown'] }}
      </VButton>
      <VButton
        v-if="vSplit === 0 && $can('edit', 'Motor::Query', query)"
        size="large"
        class="bg-white me-2 md-icon-only"
        icon="md-create"
        @click="openEditor"
      >
        {{ i18n['edit'] }}
      </VButton>
      <VButton
        v-if="canSaveNew && vSplit !== 0"
        size="large"
        class="bg-white me-2 d-none d-sm-block"
        @click="saveAsNew"
      >
        {{ i18n['save_as_new'] }}
      </VButton>
      <VButton
        v-if="canSave"
        size="large"
        ghost
        type="primary"
        class="bg-white me-2"
        @click="save"
      >
        {{ i18n['save'] }}
      </VButton>
      <VButton
        size="large"
        type="primary"
        :loading="isLoading"
        data-role="run"
        icon="md-play"
        @click="loadQueryData"
      />
    </div>
  </div>
  <div
    :style="{ height: isVariablesForm ? 'calc(var(--vh, 100vh) - 218px)' : 'calc(var(--vh, 100vh) - 135px)' }"
    class="row border-top m-0"
  >
    <div
      v-if="isSettingsOpened"
      class="p-0 col-12 col-md-6 col-lg-3 border-right"
    >
      <Settings
        :preferences="dataQuery.preferences"
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
          @submit="loadQueryData"
        />
      </div>

      <Split
        v-model="vSplit"
        mode="vertical"
        :style="{ height: isSettingsOpened && isVariablesForm ? 'calc(100% - 82px)' : '100%' }"
        @update:model-value="saveSplitPosition"
      >
        <template #top>
          <template v-if="vSplit > 0 && isCanEdit">
            <CodeEditor
              v-if="dataQuery.preferences.visualization === 'markdown' && isMarkdownEditor"
              v-model="dataQuery.preferences.visualization_options.markdown"
              language="markdown"
              :columns="columns"
              :placeholder="'## Heading'"
              :variables="dataQuery.preferences.variables"
              @run="loadQueryData"
            />
            <CodeEditor
              v-else
              v-model="dataQuery.sql_body"
              language="pgsql"
              placeholder="SELECT * FROM ..."
              :variables="dataQuery.preferences.variables"
              @run="loadQueryData"
            />
          </template>
        </template>
        <template #bottom>
          <Spin
            v-if="isLoading || isLoadingQuery"
            fix
          />
          <div
            v-else-if="!data.length && !errors.length"
            class="d-flex justify-content-center align-items-center"
            style="height: 100%"
          >
            {{ i18n['no_data'] }}
          </div>
          <QueryResult
            v-if="(data.length || errors.length) && !isLoadingQuery"
            :data="data"
            :errors="errors"
            :title="query.name"
            :columns="columns"
            :query-id="query.id"
            :with-alert="!!query.id && $can('create', 'Motor::Alert')"
            :with-settings="isCanEdit"
            :with-table-toggle="true"
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
import CodeEditor from 'utils/components/code_editor'
import QueryResult from '../components/result'
import QueryForm from '../components/form'
import Settings from '../components/settings'
import throttle from 'view3/src/utils/throttle'
import VariablesForm from '../components/variables_form'
import { titleize } from 'utils/scripts/string'
import singularize from 'inflected/src/singularize'
import { widthLessThan } from 'utils/scripts/dimensions'
import { modelNameMap } from 'data_resources/scripts/schema'
import { queriesStore } from 'reports/scripts/store'
import RevisionsModal from 'utils/components/revisions_modal'

import api from 'api'

const SPLIT_POSITION_KEY = 'motor:queries:vsplit'
const RESERVED_VARIABLES = ['current_user', 'current_user_id', 'current_user_email']

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
    queryParamsVariables () {
      return this.$route.query || {}
    },
    defaultVariablesData () {
      return (this.dataQuery.preferences.variables || []).reduce((acc, variable) => {
        acc[variable.name] = variable.default_value ?? ''

        return acc
      }, {})
    },
    defaultSplit () {
      return 0.35
    },
    cachedQueryName () {
      return queriesStore.find((q) => q.id.toString() === this.$route.params?.id)?.name
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
      return this.dataQuery.sql_body && this.isEdit && this.isCanEdit
    },
    canSaveNew () {
      return this.query.id && this.isEdited && this.$can('create', 'Motor::Query')
    },
    isCanEdit () {
      return this.query.id ? this.$can('edit', 'Motor::Query', this.query) : this.$can('create', 'Motor::Query')
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
      const isQueryChanged = to.params.id?.toString() !== this.query.id?.toString()

      if (!isQueryChanged && (to.name === 'query' || to.name === 'new_query') && JSON.stringify(to.query || {}) !== JSON.stringify(from.query || {})) {
        this.assignVariablesData()
        this.loadQueryData()
      }

      if (isQueryChanged && to.name === 'query') {
        this.onMounted()
      }

      if (to.name === 'new_query') {
        if (isQueryChanged) {
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
          if (location.hash) {
            location.hash = ''
          }
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
    openRevisionsModal () {
      this.$Drawer.open(RevisionsModal, {
        auditableName: 'query',
        auditableId: this.query.id,
        onRevert: (data) => {
          Object.assign(this.dataQuery, {
            sql_body: data.sql_body,
            preferences: data.preferences
          })

          this.query.name = data.name

          this.$Message.info(this.i18n.revision_has_been_applied)
          this.openEditor()
          this.$Drawer.remove()
        }
      }, {
        closable: true,
        title: this.i18n.query_revisions
      })
    },
    assignDataFromLocationHash () {
      this.dataQuery = JSON.parse(JSON.stringify(this.locationHashParams)) || { ...defaultQueryParams }
      this.dataQuery.preferences = { ...defaultQueryParams.preferences, ...this.dataQuery.preferences }
    },
    assignVariablesData () {
      this.variablesData = { ...this.defaultVariablesData, ...this.queryParamsVariables }
    },
    toggleSettings () {
      this.isSettingsOpened = !this.isSettingsOpened
    },
    onMounted () {
      this.assignVariablesData()

      this.vSplit = 0

      if (this.$route.params.id) {
        this.loadQuery()
      } else {
        this.query = JSON.parse(JSON.stringify(defaultQueryParams))
        this.data = []
        this.columns = []
        this.openEditor()

        if (this.dataQuery.sql_body) {
          this.assignVariablesData()
          this.loadQueryData()
        }
      }
    },
    openEditor () {
      this.vSplit = JSON.parse(localStorage.getItem(SPLIT_POSITION_KEY)) || 0.35
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
          }
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
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isLoadingQuery = false
      })

      this.loadQueryData()
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
            if (!RESERVED_VARIABLES.includes(variableName)) {
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
            }
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
          tags: this.query.tags.map((t) => t.name),
          sql_body: this.dataQuery.sql_body,
          preferences: this.dataQuery.preferences
        },
        action: this.query.id ? 'edit' : 'new',
        onSuccess: (result) => {
          this.query = result
          this.$Modal.remove()
          this.$Message.info(this.i18n.query_has_been_saved)

          this.$router.push({ name: 'query', params: { id: result.id }, query: this.$route.query })
        }
      }, {
        title: this.i18n.save_query,
        closable: true
      })
    },
    saveSplitPosition () {
      localStorage.setItem(SPLIT_POSITION_KEY, JSON.stringify(this.vSplit))
    },
    saveAsNew () {
      this.$Modal.open(QueryForm, {
        query: {
          name: this.query.name,
          description: this.query.description,
          tags: this.query.tags.map((t) => t.name),
          preferences: this.dataQuery.preferences,
          sql_body: this.dataQuery.sql_body
        },
        action: 'new',
        onSuccess: (result) => {
          this.query = result
          this.$Modal.remove()
          this.$Message.info(this.i18n.query_has_been_saved)

          this.$router.push({ name: 'query', params: { id: result.id }, query: this.$route.query })
        }
      }, {
        title: this.i18n.save_query,
        closable: true
      })
    },
    maybeUpdateVariablesQueryParams () {
      const hashString = this.dataQueryString !== this.queryString ? this.queryDataLocationHashString : ''

      if (Object.keys(this.defaultVariablesData).length) {
        const nonDefaultVariablesData = Object.keys(this.defaultVariablesData).reduce((acc, key) => {
          if ((this.variablesData[key] ?? '').toString() !== (this.defaultVariablesData[key] ?? '').toString()) {
            acc[key] = this.variablesData[key]
          }

          return acc
        }, {})

        if (Object.keys(nonDefaultVariablesData).length) {
          this.$router.replace({ query: { ...nonDefaultVariablesData }, hash: hashString })
        } else if (Object.keys(this.queryParamsVariables).length) {
          this.$router.replace({ query: null, hash: hashString })
        }
      }
    },
    loadQueryData () {
      this.maybeUpdateVariablesQueryParams()

      if (this.dataQuery.sql_body && (this.isEdited || !this.query.id)) {
        return this.runQuery()
      } else if (this.$route.params.id) {
        return this.runExistingQuery()
      }
    },
    runExistingQuery () {
      if (!this.isLoading) {
        this.isLoading = true

        return api.get(`run_queries/${this.$route.params.id}`, {
          params: {
            variables: this.variablesData
          }
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
    runQuery () {
      if (!this.isLoading) {
        this.isLoading = true

        return api.post('run_queries', {
          data: this.dataQuery,
          variables: this.variablesData
        }).then((result) => {
          this.errors = []
          this.data = result.data.data
          this.columns = result.data.meta.columns
        }).catch((error) => {
          if (error.response) {
            this.errors = error.response.data?.errors
          } else {
            this.$Message.error(error.message)
          }
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
