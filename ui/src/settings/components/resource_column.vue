<template>
  <div
    class="ivu-card ivu-card-bordered"
    @click="toggleForm"
  >
    <div class="ivu-card-body py-0">
      <div
        class="cursor-pointer d-flex align-items-center justify-content-between py-2"
        :style="{ opacity: !isForm && column.access_type === 'hidden' ? 0.5 : 1 }"
      >
        <div class="d-flex align-items-center">
          <Icon
            type="ios-menu"
            class="me-3 cursor-grab"
          />
          <Checkbox
            :model-value="['read_only', 'read_write'].includes(column.access_type)"
            :indeterminate="['write_only', 'read_only'].includes(column.access_type)"
            @click.stop
            @on-change="toggleAccessType"
          />
          <p
            ref="contenteditable"
            class="fs-5 fw-bold cursor-text"
            contenteditable
            @input="updateName"
            @click.stop
            @blur="onNameFocusLost"
            @keydown.enter.prevent="$refs.contenteditable.blur()"
          >
            {{ displayName }}
          </p>
        </div>
        <div class="d-flex align-items-center">
          <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
        </div>
      </div>
      <ColumnForm
        v-if="isForm"
        :column="column"
        class="py-3"
        :with-remove="column.virtual"
        @cancel="toggleForm"
        @remove="removeColumn"
        @submit="updateColumn"
        @click.stop
      />
    </div>
  </div>
</template>

<script>
import api from 'api'
import ColumnForm from './resource_column_form'
import { modelNameMap } from 'utils/scripts/schema'

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
  data () {
    return {
      isForm: false,
      displayName: this.column.display_name
    }
  },
  computed: {
    resource () {
      return modelNameMap[this.resourceName]
    }
  },
  watch: {
    column: {
      deep: true,
      handler () {
        this.displayName = this.column.display_name
      }
    }
  },
  methods: {
    removeColumn () {
      this.$Dialog.confirm({
        title: 'Are you sure?',
        closable: true,
        onOk: () => {
          const index = this.resource.columns.findIndex((column) => column.name === this.column.name)

          this.resource.columns.splice(index, 1)

          api.post('api/resource_configs', {
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
    persistChanges () {
      return api.post('api/resource_configs', {
        data: {
          name: this.resourceName,
          preferences: {
            columns: [
              this.column
            ]
          }
        }
      }).then((result) => {
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
    },
    updateName (event) {
      this.column.display_name = event.target.innerText
    },
    updateColumn (column) {
      Object.assign(this.column, column)

      this.persistChanges()

      this.isForm = false
    },
    onNameFocusLost () {
      if (!this.column.display_name || this.column.display_name.match(/^\s+$/)) {
        this.column.display_name = this.displayName
        this.displayName = this.displayName + ' '
      } else {
        this.persistChanges()

        this.displayName = this.column.display_name
      }
    }
  }
}
</script>