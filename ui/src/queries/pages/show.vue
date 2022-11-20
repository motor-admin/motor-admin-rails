<template>
  <div
    class="row mx-0 mx-md-2"
    style="min-height: 74px"
  >
    <div
      class="d-flex align-items-center"
      :class="isNewPage ? 'col-4' : 'col-8'"
    >
      <h1
        class="my-3 overflow-hidden text-truncate"
      >
        {{ query.name || cachedQueryName || (isExisting ? '' : i18n['new_query']) }}
      </h1>
    </div>
    <div
      v-if="isNewPage"
      class="col-4 d-flex align-items-center justify-content-center"
    >
      <VButton
        v-for="item in queryTypes"
        :key="item.value"
        :type="queryType === item.value ? 'primary' : 'dashed'"
        class="bg-transparent mx-1"
        :class="queryType === item.value ? 'text-primary' : 'text-dark'"
        @click="changeQueryType(item.value)"
      >
        {{ item.label }}
      </VButton>
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
        v-if="vSplit !== 0 && dataQuery.preferences.visualization === 'html'"
        size="large"
        class="me-2 md-icon-only"
        :icon="isHtmlEditor ? 'md-code-working' : 'logo-html5'"
        @click="isHtmlEditor = !isHtmlEditor"
      >
        {{ isHtmlEditor ? i18n['edit_sql'] : i18n['edit_html'] }}
      </VButton>
      <VButton
        v-if="vSplit === 0 && $can('edit', 'Motor::Query', query) && queryType === 'sql'"
        size="large"
        class="bg-white me-2 md-icon-only"
        icon="md-create"
        @click="openEditor"
      >
        {{ i18n['edit'] }}
      </VButton>
      <VButton
        v-if="canSaveNew && (vSplit !== 0 || queryType === 'api')"
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
        :with-variables-editor="queryType === 'api'"
        style="height: 100%"
        @close="toggleSettings"
      />
    </div>
    <div
      class="p-0"
      :class="{ 'col-6 col-lg-9 d-none d-md-inline' : isSettingsOpened, 'col-12': !isSettingsOpened, 'h-100': queryType === 'api' }"
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
      <div
        v-if="showApiUi"
        style="height: calc(100% - 64px)"
      >
        <div
          v-if="isCanEdit && (isMarkdownEditor || isHtmlEditor)"
          class="border-bottom"
          style="height: 40%"
        >
          <CodeEditor
            v-if="dataQuery.preferences.visualization === 'markdown' && isMarkdownEditor"
            v-model="dataQuery.preferences.visualization_options.markdown"
            language="markdown"
            :columns="columns"
            :autofocus="true"
            :placeholder="'## Heading'"
            :variables="dataQuery.preferences.variables"
            @run="loadQueryData"
          />
          <CodeEditor
            v-else-if="dataQuery.preferences.visualization === 'html' && isHtmlEditor"
            v-model="dataQuery.preferences.visualization_options.html"
            language="liquid"
            :columns="columns"
            :autofocus="true"
            :placeholder="'<div>Liquid HTML template: {{column}}</div>'"
            :variables="dataQuery.preferences.variables"
            @run="loadQueryData"
          />
        </div>
        <div
          class="p-3 bg-white d-flex"
          :class="{ 'border-bottom': !data.length && !errors.length }"
        >
          <ApiSelect
            v-model="dataQuery.preferences.api_config_name"
            class="w-50 pe-1"
          />
          <VInput
            v-model="dataQuery.preferences.api_path"
            class="w-50 ps-1"
            :placeholder="i18n.api_path"
            @keyup.enter="loadQueryData"
          />
          <VButton
            icon="md-settings"
            class="ms-2"
            @click="toggleSettings"
          >
            {{ i18n.settings }}
          </VButton>
        </div>
        <div
          class="position-relative"
          :style="{ height: isMarkdownEditor || isHtmlEditor ? '60%' : '100%' }"
        >
          <Spin
            v-if="isLoading || isLoadingQuery"
            fix
          />
          <div
            v-else-if="!data.length && !errors.length && !dataHTML"
            class="d-flex justify-content-center align-items-center h-100"
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
            :with-alert="!!query.id && $can('create', 'Motor::Alert') && queryType !== 'api'"
            :with-settings="isCanEdit"
            :with-table-toggle="true"
            :show-markdown-table="!widthLessThan('md') && isEdit"
            :preferences="dataQuery.preferences"
            @settings="toggleSettings"
          />
          <div
            v-else-if="dataHTML"
            class="h-100 overflow-auto"
            v-html="dataHTML"
          />
        </div>
      </div>
      <Split
        v-else
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
              :autofocus="true"
              :columns="columns"
              :placeholder="'## Heading'"
              :variables="dataQuery.preferences.variables"
              @run="loadQueryData"
            />
            <CodeEditor
              v-else-if="dataQuery.preferences.visualization === 'html' && isHtmlEditor"
              v-model="dataQuery.preferences.visualization_options.html"
              language="liquid"
              :autofocus="true"
              :columns="columns"
              :placeholder="'<div>Liquid HTML template: {{column}}</div>'"
              :variables="dataQuery.preferences.variables"
              @run="loadQueryData"
            />
            <CodeEditor
              v-else
              v-model="dataQuery.sql_body"
              language="pgsql"
              :autofocus="true"
              placeholder="SELECT * FROM ..."
              :variables="dataQuery.preferences.variables"
              @run="loadQueryData"
            />
            <div
              v-if="databaseNames.length > 1"
              style="position: relative; bottom: 31px; right: -1px; z-index: 10"
            >
              <MSelect
                v-model="dataQuery.preferences.database"
                :options="databaseNames"
                class="float-right"
                :with-deselect="false"
                style="float: right; width: 200px"
                :option-component="dbLabelComponent"
                data-role="db-selector"
                @update:model-value="loadQueryData"
              />
            </div>
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
import ApiSelect from 'api_configs/components/select'
import { databaseNames } from 'utils/scripts/configs'
import DbLabel from '../components/db_label'

import api from 'api'
import { loadApiQuery } from '../scripts/api_query'

const SPLIT_POSITION_KEY = 'motor:queries:vsplit'
const RESERVED_VARIABLES = ['current_user', 'current_user_id', 'current_user_email']

const defaultQueryParams = {
  name: '',
  sql_body: '',
  tags: [],
  preferences: {
    query_type: 'sql',
    database: (databaseNames.includes('Default') ? 'Default' : 'primary'),
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
    VariablesForm,
    ApiSelect
  },
  data () {
    return {
      vSplit: 0,
      isLoading: false,
      isLoadingQuery: false,
      isMarkdownEditor: false,
      isHtmlEditor: false,
      query: { ...defaultQueryParams },
      dataQuery: {
        sql_body: '',
        preferences: {}
      },
      variablesData: {},
      isSettingsOpened: false,
      errors: [],
      columns: [],
      data: [],
      dataHTML: ''
    }
  },
  computed: {
    databaseNames: () => databaseNames,
    dbLabelComponent: () => DbLabel,
    queryParamsVariables () {
      return this.$route.query || {}
    },
    queryType () {
      return this.dataQuery.preferences.query_type || 'sql'
    },
    isNewPage () {
      return this.$route.name === 'new_query' && !this.query.id
    },
    showApiUi () {
      return this.queryType === 'api' || (!this.isNewPage && this.dataQuery.preferences.api_path)
    },
    queryTypes () {
      return [
        { label: this.i18n.sql, value: 'sql' },
        { label: this.i18n.api, value: 'api' }
      ]
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
      return (this.dataQuery.sql_body || this.dataQuery.preferences.api_path) && this.isEdit && this.isCanEdit
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
      if (this.dataQuery.preferences.query_type !== 'api') {
        this.assignVariablesFromSql(value)
      }
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
    changeQueryType (value) {
      this.dataQuery.preferences.query_type = value

      this.data = []
      this.columns = []
    },
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

        if (this.dataQuery.sql_body || this.dataQuery.preferences.api_path) {
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

      return api.get(`queries/${this.$route.params.id}`, {
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

        return this.loadQueryData()
      }).catch((error) => {
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.isLoadingQuery = false
      })
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
            if (!RESERVED_VARIABLES.includes(variableName) && !variableName.match(/_database_url$/)) {
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

      if (this.queryType === 'api') {
        return this.runApiQuery()
      } else {
        if (this.dataQuery.sql_body && (this.isEdited || !this.query.id)) {
          return this.runQuery()
        } else if (this.$route.params.id) {
          return this.runExistingQuery()
        }
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
    runApiQuery () {
      if (!this.isLoading) {
        this.isLoading = true

        return loadApiQuery(this.dataQuery, this.variablesData).then((result) => {
          this.errors = []

          this.data = result.data || []
          this.columns = result.columns || []
          this.dataHTML = result.dataHTML || ''
        }).catch((error) => {
          console.error(error)

          if (error.response) {
            this.errors = error.response?.data?.errors || [error.message]
          } else {
            this.$Message.error(error.message)
          }
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
            this.errors = error.response.data?.errors || [error.message]
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
[data-role="db-selector"] {
  .ivu-select-selection {
    border-bottom-right-radius: 0;
    border-bottom-left-radius: 0;
    border-top-right-radius: 0;
  }
}
</style>
