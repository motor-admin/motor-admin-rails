<template>
  <div :style="style">
    <Spin
      v-if="isLoadingQuery"
      fix
    />
    <template v-else>
      <VariablesForm
        v-if="showVariablesForm"
        v-model:data="dataVariables"
        :variables="variablesToRender"
        class="mx-2 pb-3"
        @submit="runQuery"
      />
      <Spin
        v-if="isLoading"
        fix
      />
      <div
        v-else-if="!data.length && !isIframe"
        class="d-flex justify-content-center align-items-center"
        style="height: 100%"
      >
        {{ i18n['no_data'] }}
      </div>
      <QueryResult
        v-if="data.length"
        :data="data"
        :errors="errors"
        :title="query.name"
        :columns="columns"
        :query-id="query.id"
        :with-footer="query.preferences.visualization !== 'markdown'"
        :with-settings="false"
        :header-border="showVariablesForm"
        :preferences="query.preferences"
      />
      <div
        v-else-if="isIframe"
        style="overflow: hidden; height: 100%"
      >
        <iframe
          :src="iframeSrc"
          :style="{ height: '100%', border: 0, width: '100%' }"
        />
      </div>
    </template>
  </div>
</template>

<script>
import QueryResult from 'queries/components/result'
import { interpolateForQueryParams } from 'utils/scripts/string'
import VariablesForm from 'queries/components/variables_form'
import api from 'api'

export default {
  name: 'QueryTab',
  components: {
    QueryResult,
    VariablesForm
  },
  props: {
    variables: {
      type: Object,
      required: false,
      default: () => ({})
    },
    tab: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      isLoading: false,
      isLoadingQuery: true,
      dataVariables: { ...this.variables },
      errors: [],
      data: [],
      columns: [],
      iframeSrc: '',
      query: {}
    }
  },
  computed: {
    queryId () {
      return this.tab.preferences.query_id
    },
    isIframe () {
      return this.query?.preferences?.visualization === 'iframe'
    },
    style () {
      if (this.isLoadingQuery || !this.showVariablesForm) {
        return 'height: 100%'
      } else {
        return 'height: calc(100% - 78px)'
      }
    },
    variablesToRender () {
      return (this.query.preferences.variables || []).filter((variable) => !this.variables[variable.name])
    },
    showVariablesForm () {
      return !!this.variablesToRender.length
    }
  },
  mounted () {
    this.loadQuery().then(() => {
      if (this.isIframe) {
        const [apiPath, queryParams] = interpolateForQueryParams(this.query.preferences.api_path, {
            ...this.dataVariables,
            ...this.variables
        })

        console.log(this.query.preferences.api_path, this.variables)
        this.iframeSrc = `${apiPath}?${new URLSearchParams(queryParams).toString()}`
      } else {
        this.runQuery()
      }
    })
  },
  methods: {
    loadQuery () {
      return api.get(`queries/${this.queryId}`, {
      }).then((result) => {
        this.query = result.data.data

        this.assignDataVariables()
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoadingQuery = false
      })
    },
    assignDataVariables () {
      this.dataVariables = (this.query.preferences.variables || []).reduce((acc, variable) => {
        acc[variable.name] = variable.default_value

        return acc
      }, {})
    },
    runQuery () {
      this.isLoading = true

      return api.get(`run_queries/${this.queryId}`, {
        params: {
          variables: {
            ...this.dataVariables,
            ...this.variables
          }
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
  }
}
</script>
