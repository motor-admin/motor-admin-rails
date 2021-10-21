<template>
  <div class="d-flex">
    <Dropdown
      v-if="canEditCustomForm || canBuildCustomForm || canAdjustColumns"
      trigger="click"
      placement="bottom-start"
    >
      <VButton
        type="text"
        size="large"
        class="header-btn"
      >
        <Icon
          type="md-more"
          size="large"
        />
      </VButton>
      <template #list>
        <DropdownMenu>
          <DropdownItem
            v-if="canEditCustomForm"
            @click="$router.push({ name: 'form', params: { id: customForm.id } })"
          >
            {{ i18n['adjust_form'] }}
          </DropdownItem>
          <DropdownItem
            v-if="canAdjustColumns"
            @click="openColumnSettings"
          >
            {{ i18n['adjust_fields'] }}
          </DropdownItem>
          <DropdownItem
            v-if="canBuildCustomForm"
            @click="$router.push({ name: 'new_form', query: { resource: model.name, action } })"
          >
            {{ i18n['build_custom_form'] }}
          </DropdownItem>
        </DropdownMenu>
      </template>
    </Dropdown>
    <div class="ivu-drawer-header-inner">
      {{ headerTitle }}
    </div>
  </div>
</template>

<script>
import { modelNameMap } from '../scripts/schema'
import singularize from 'inflected/src/singularize'
import { formsStore } from 'custom_forms/scripts/store'
import { openSettingsDrawer } from 'settings/scripts/drawer'

export default {
  name: 'FormHeader',
  props: {
    resource: {
      type: Object,
      required: false,
      default: () => ({})
    },
    resourceName: {
      type: String,
      required: true
    },
    action: {
      type: String,
      required: true
    }
  },
  computed: {
    canEditCustomForm () {
      return this.customForm && this.$can('update', 'Motor::Form', this.customForm)
    },
    canBuildCustomForm () {
      return !this.customForm && this.$can('create', 'Motor::Form')
    },
    canAdjustColumns () {
      return !this.customForm && this.$can('update', 'Motor::Resource', this.model)
    },
    customForm () {
      const formId = this.modelAction?.preferences?.form_id

      if (formId) {
        return formsStore.find((form) => form.id.toString() === formId.toString())
      } else {
        return null
      }
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    modelAction () {
      return this.model.actions.find((action) => action.name === this.action)
    },
    headerTitle () {
      return `${this.modelAction.display_name} ${this.resourceTitle}`
    },
    resourceTitle () {
      if (this.model.primary_key in this.resource) {
        return `${singularize(this.model.display_name)} #${this.resource[this.model.primary_key]}`
      } else {
        return singularize(this.model.display_name)
      }
    }
  },
  methods: {
    openColumnSettings () {
      this.$Drawer.remove()

      openSettingsDrawer({
        selectedResource: this.model,
        settingsType: 'columns'
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-btn {
  height: auto;
  font-size: 17px;
  padding: 0 5px;
}

.ivu-dropdown {
  margin-top: -3px;
  max-height: 20px
}
</style>
