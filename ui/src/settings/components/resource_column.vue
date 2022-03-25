<template>
  <div>
    <div
      class="ivu-card ivu-card-bordered"
    >
      <div class="ivu-card-body py-0">
        <div
          class="cursor-pointer d-flex align-items-center justify-content-between py-2"
          :style="{ opacity: !isForm && column.access_type === 'hidden' ? 0.5 : 1 }"
          @click="toggleForm"
        >
          <div class="d-flex align-items-center">
            <Icon
              type="ios-menu"
              class="me-3 cursor-grab handle"
            />
            <Checkbox
              :model-value="['read_only', 'read_write'].includes(column.access_type)"
              :indeterminate="['write_only', 'read_only'].includes(column.access_type)"
              @click.stop
              @on-change="toggleAccessType"
            />
            <Contenteditable
              v-model="column.display_name"
              class="fs-5 fw-bold"
              @click.stop
              @change="persistChanges()"
            />
          </div>
          <div class="d-flex align-items-center">
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <ColumnForm
          v-if="isForm"
          :column="column"
          :resource-name="resourceName"
          class="py-3"
          :with-remove="column.virtual"
          @cancel="toggleForm"
          @remove="removeColumn"
          @submit="updateColumn"
        />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import ColumnForm from './resource_column_form'
import { modelNameMap } from 'data_resources/scripts/schema'
import { underscore } from 'utils/scripts/string'

export default {
  name: 'ResourceColumn',
  components: {
    ColumnForm
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    column: {
      type: Object,
      required: true
    }
  },
  emits: ['reorder'],
  data () {
    return {
      isForm: false
    }
  },
  computed: {
    resource () {
      return modelNameMap[this.resourceName]
    }
  },
  methods: {
    removeColumn () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: () => {
          const index = this.resource.columns.findIndex((column) => column.name === this.column.name)

          this.resource.columns.splice(index, 1)

          api.post('resources', {
            data: {
              name: this.resourceName,
              preferences: {
                columns: [
                  {
                    name: this.column.name,
                    _remove: true
                  }
                ]
              }
            }
          }).then((result) => {
          }).catch((error) => {
            console.error(error)
          })
        }
      })
    },
    persistChanges (column = null) {
      const dataColumn = { ...(column || this.column) }

      if (dataColumn.name) {
        dataColumn._update = dataColumn.name
      }

      if (dataColumn.virtual && dataColumn.column_type !== 'association') {
        dataColumn.name = underscore(dataColumn.display_name)
      }

      return api.post('resources', {
        data: {
          name: this.resourceName,
          preferences: {
            columns: [dataColumn]
          }
        }
      }).then((result) => {
        if (this.column.name !== dataColumn.name) {
          this.column.name = dataColumn.name

          this.$emit('reorder')
        }
      }).catch((error) => {
        console.error(error)
      })
    },
    toggleAccessType (value) {
      if (value) {
        this.column.access_type = 'read_write'
      } else {
        this.column.access_type = 'hidden'
      }

      this.persistChanges()
    },
    toggleForm () {
      this.isForm = !this.isForm

      if (this.isForm) {
        this.$nextTick(() => {
          this.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    updateName (event) {
      this.column.display_name = event.target.innerText
    },
    updateColumn (column) {
      this.persistChanges(column).then(() => {
        Object.assign(this.column, column)
      })

      this.isForm = false
    }
  }
}
</script>
