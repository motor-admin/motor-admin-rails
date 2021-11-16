<template>
  <div>
    <div class="ivu-card ivu-card-bordered">
      <div class="ivu-card-body">
        <div
          class="cursor-pointer d-flex align-items-center justify-content-between"
          :style="{ opacity: !isForm && association.visible ? 1 : 0.5 }"
          @click="toggleForm"
        >
          <div class="d-flex align-items-center">
            <Icon
              type="ios-menu"
              class="me-3 cursor-grab handle"
            />
            <Checkbox
              v-model="association.visible"
              class="m-0"
              @click.stop
              @change="persistChanges()"
            />
            <CustomIcon
              :type="association.icon"
              :size="26"
              class="p-1 mx-1 cursor-pointer"
              @click.stop="openIconEditor"
            />
            <Contenteditable
              v-model="association.display_name"
              class="fs-5 fw-bold"
              @click.stop
              @change="persistChanges()"
            />
          </div>
          <div
            v-if="association.virtual"
            class="d-flex align-items-center"
          >
            <Icon :type="isForm ? 'ios-arrow-up' : 'ios-arrow-down'" />
          </div>
        </div>
        <AssociationForm
          v-if="isForm"
          :association="association"
          :resource-name="resourceName"
          class="py-3"
          :with-remove="true"
          @cancel="toggleForm"
          @remove="removeAssociation"
          @submit="updateAssociation"
        />
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import CustomIcon from 'utils/components/custom_icon'
import AssociationForm from './resource_association_form'
import IconSelect from './icon_select'
import { modelNameMap } from 'data_resources/scripts/schema'

export default {
  name: 'AssociationItem',
  components: {
    CustomIcon,
    AssociationForm
  },
  props: {
    resourceName: {
      type: String,
      required: true
    },
    association: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      isForm: false
    }
  },
  computed: {
    model () {
      return modelNameMap[this.resourceName]
    }
  },
  methods: {
    removeAssociation () {
      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: () => {
          const index = this.model.associations.findIndex((assoc) => assoc.name === this.association.name)

          this.model.associations.splice(index, 1)

          api.post('resources', {
            data: {
              name: this.resourceName,
              preferences: {
                associations: [
                  {
                    name: this.association.name,
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
    openIconEditor () {
      this.$Modal.open(IconSelect, {
        onSelect: (icon) => {
          this.association.icon = icon

          this.persistChanges()

          this.$Modal.remove()
        },
        onClose: () => {
          this.$Modal.remove()
        }
      })
    },
    toggleForm () {
      if (this.association.virtual) {
        this.isForm = !this.isForm

        this.$nextTick(() => {
          this.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    updateAssociation (assoc) {
      this.persistChanges(assoc).then(() => {
        Object.assign(this.association, assoc)
      })

      this.isForm = false
    },
    persistChanges (association) {
      return api.post('resources', {
        data: {
          name: this.resourceName,
          preferences: {
            associations: [
              association || this.association
            ]
          }
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-card-body {
  padding: 5px 16px 6px 16px;
}
</style>
