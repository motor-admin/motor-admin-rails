<template>
  <div>
    <CodeEditor
      v-model="sqlBody"
      style="height: 140px"

      :autofocus="true"
      language="pgsql"
      placeholder="SELECT * FROM ..."
      @run="runQuery"
    />
    <div
      style="height: 190px"
      class="pb-2 position-relative"
    >
      <Spin
        v-if="isLoading"
        fix
      />
      <div
        v-else-if="!data.length && !errors.length"
        class="d-flex justify-content-center align-items-center"
        style="height: 100%"
      >
        {{ i18n.no_data }}
      </div>
      <QueryResult
        v-if="(data.length || errors.length)"
        :data="data"
        :errors="errors"
        :columns="columns"
        :with-footer="false"
      />
    </div>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          class="me-2"
          @click="$emit('close')"
        >
          {{ i18n.cancel }}
        </VButton>
        <VButton
          type="error"
          ghost
          class="me-2"
          @click="resetDefault"
        >
          {{ i18n.use_default }}
        </VButton>
      </div>
      <div>
        <VButton
          class="me-2"
          :loading="isLoading"
          icon="md-play"
          @click="runQuery"
        >
          {{ i18n.run }}
        </VButton>
        <VButton
          type="primary"
          :loading="isLoadingSave"
          @click="submit"
        >
          {{ i18n.save }}
        </VButton>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import CodeEditor from 'utils/components/code_editor'
import QueryResult from 'queries/components/result'
import { databaseNames } from 'utils/scripts/configs'

export default {
  name: 'ResourceQueryForm',
  components: {
    CodeEditor,
    QueryResult
  },
  props: {
    resource: {
      type: Object,
      required: true
    }
  },
  emits: ['close'],
  data () {
    return {
      sqlBody: '',
      collapseValue: '',
      isLoading: false,
      isLoadingSave: false,
      data: [],
      errors: [],
      columns: []
    }
  },
  async mounted () {
    this.isLoading = true

    if (this.resource.custom_sql) {
      this.sqlBody = this.resource.custom_sql
    } else {
      await this.loadDefaultQuery()
    }

    this.runQuery()
  },
  methods: {
    resetDefault () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: async () => {
          await this.loadDefaultQuery()

          this.submit()
          this.runQuery()
        }
      })
    },
    submit () {
      this.isLoadingSave = true

      return api.post('resources', {
        data: {
          name: this.resource.name,
          preferences: {
            custom_sql: this.sqlBody
          }
        }
      }).then((result) => {
        this.reloadSchema().then(() => {
          this.$Message.info(this.i18n.query_has_been_saved)
        })
      }).catch((error) => {
        console.error(error)
      }).finally(() => {
        this.isLoadingSave = false
      })
    },
    reloadSchema () {
      return api.get(`schema/${this.resource.slug}`).then((result) => {
        Object.assign(this.resource, result.data.data)
      })
    },
    loadDefaultQuery () {
      return api.get(`resource_default_queries/${this.resource.slug}`).then((result) => {
        this.sqlBody = result.data.data.sql
      })
    },
    runQuery () {
      this.isLoading = true

      const databaseName =
        this.resource.name.includes('/') ? this.resource.name.split('/')[0] : 'default'

      return api.post('run_queries', {
        limit: 20,
        data: {
          sql_body: this.sqlBody,
          preferences: {
            database: databaseNames.includes(databaseName) ? databaseName : 'default'
          }
        }
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
</script>
