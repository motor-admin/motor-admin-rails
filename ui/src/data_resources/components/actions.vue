<template>
  <template v-if="withButtons">
    <VButton
      v-for="(action, index) in buttonActions"
      :key="action.name"
      :class="index !== (buttonActions.length - 1) || (withDropdown && dropdownActions.length) ? 'me-2' : ''"
      :type="buttonTypes[action.name]"
      :ghost="!!buttonTypes[action.name]"
      :size="buttonSize"
      @click="applyAction(action)"
    >
      {{ action.display_name }}
    </VButton>
  </template>
  <Dropdown
    v-if="(withDeselect || hasActions) && withDropdown && dropdownActions.length"
    trigger="click"
    :placement="placement"
    :class="$attrs.class"
    @on-visible-change="onDropdownVisibleChange"
  >
    <VButton
      :ghost="buttonGhost"
      :type="buttonType"
      class="w-100"
      :size="buttonSize"
      :class="{ 'bg-white': buttonGhost }"
    >
      {{ dropdownLabel }}
      <Icon :type="buttonIcon" />
    </VButton>
    <template #list>
      <DropdownMenu>
        <template
          v-for="action in customActions"
          :key="action.name"
        >
          <DropdownItem
            v-if="dropdownActions.indexOf(action) !== -1"
            :disabled="resources.length > 1 && (!isActionWithBatchAllowed(action) || action.preferences.flow_id)"
            @click="applyAction(action)"
          >
            {{ action.display_name }}
          </DropdownItem>
        </template>
        <DropdownItem
          v-if="editAction && canEdit && dropdownActions.indexOf(editAction) !== -1"
          :disabled="resources.length > 1"
          @click="applyAction(editAction)"
        >
          {{ i18n['edit'] }}
        </DropdownItem>
        <DropdownItem
          v-if="removeAction && canRemove && dropdownActions.indexOf(removeAction) !== -1"
          :divided="!!editAction"
          class="text-danger"
          @click="applyAction(removeAction)"
        >
          {{ i18n['remove'] }}
        </DropdownItem>
        <DropdownItem
          v-if="withDeselect"
          :divided="hasActions"
          @click="deselect"
        >
          {{ i18n['deselect_all'] }}
        </DropdownItem>
      </DropdownMenu>
    </template>
  </Dropdown>
</template>

<script>
import api from 'api'
import { h } from 'vue'
import { modelNameMap } from '../scripts/schema'
import ResourceForm from './form'
import FormHeader from 'data_resources/components/form_header'
import { interpolate, truncate } from 'utils/scripts/string'
import CustomFormWrapper from 'custom_forms/components/form_wrapper'
import { formsCache, loadFormFromCache, loadFormsToCache } from 'custom_forms/scripts/cache'
import singularize from 'inflected/src/singularize'
import { i18nDict } from 'utils/scripts/configs'
import { loadCredentials } from 'utils/scripts/auth_credentials'
import axios from 'axios'

const MAX_BUTTONS_LENGTH = 50

export default {
  name: 'ResourceActions',
  props: {
    resources: {
      type: Array,
      required: true
    },
    actions: {
      type: Array,
      required: false,
      default: null
    },
    buttonIcon: {
      type: String,
      required: false,
      default: 'ios-arrow-down'
    },
    buttonType: {
      type: String,
      required: false,
      default: 'primary'
    },
    buttonSize: {
      type: String,
      required: false,
      default: 'default'
    },
    buttonGhost: {
      type: Boolean,
      required: false,
      default: true
    },
    withDeselect: {
      type: Boolean,
      required: false,
      default: false
    },
    withButtons: {
      type: Boolean,
      required: false,
      default: false
    },
    withDropdown: {
      type: Boolean,
      required: false,
      default: true
    },
    placement: {
      type: String,
      required: false,
      default: 'bottom'
    },
    resourceName: {
      type: String,
      required: true
    },
    label: {
      type: String,
      required: false,
      default: i18nDict.actions
    }
  },
  emits: ['start-action', 'finish-action'],
  computed: {
    formsCache () {
      return formsCache
    },
    dropdownLabel () {
      if (this.i18n.actions !== this.label) {
        return this.label
      } else {
        return this.buttonActions.length ? this.i18n.more : this.i18n.actions
      }
    },
    requestHeaders () {
      const headers = {}
      const csrfTag = document.querySelector('[name="csrf-token"]')

      if (csrfTag) {
        headers['X-CSRF-Token'] = csrfTag.content
      }

      return headers
    },
    buttonTypes () {
      return {
        edit: 'primary',
        remove: 'error'
      }
    },
    partitionedActions () {
      return this.permittedActions.reduce(([buttonActions, dropdownActions, len], action) => {
        if (len < MAX_BUTTONS_LENGTH) {
          len += action.display_name.length + 6
          buttonActions.push(action)
        } else {
          dropdownActions.push(action)
        }

        return [buttonActions, dropdownActions, len]
      }, [[], [], 0]).slice(0, 2)
    },
    buttonActions () {
      if (!this.withButtons) {
        return []
      }

      if (this.partitionedActions[1].length > 1) {
        return this.partitionedActions[0]
      } else {
        return this.permittedActions
      }
    },
    dropdownActions () {
      if (!this.withButtons) {
        return this.permittedActions
      }

      if (this.partitionedActions[1].length > 1) {
        return this.partitionedActions[1]
      } else {
        return []
      }
    },
    resource () {
      return this.resources[0]
    },
    editAction () {
      return this.model.actions.find((action) => {
        return action.name === 'edit' && action.visible
      })
    },
    removeAction () {
      return this.model.actions.find((action) => {
        return action.name === 'remove' && action.visible
      })
    },
    canEdit () {
      return this.model.primary_key && this.resources.some((res) => this.$can('edit', this.model.class_name, res))
    },
    canRemove () {
      return this.model.primary_key && this.resources.some((res) => this.$can('destroy', this.model.class_name, res))
    },
    hasActions () {
      return this.canEdit || this.canRemove || this.customActions.length > 0
    },
    customActions () {
      return this.permittedActions.filter((action) => {
        return !['create', 'edit', 'remove'].includes(action.name)
      })
    },
    permittedActions () {
      return (this.actions || this.model.actions).filter((action) => {
        return action.apply_on === 'member' && action.visible && this.resources.some((res) => {
          return this.$can(action.name, this.model.class_name, res)
        })
      })
    },
    model () {
      return modelNameMap[this.resourceName]
    }
  },
  methods: {
    deselect () {
      this.resources.forEach((resource) => {
        resource._selected = false
      })
    },
    methodRequest (resource, action) {
      return api.put(`data/${this.model.slug}/${resource[this.model.primary_key]}/${action.preferences.method_name}`, {}, {
        responseType: 'blob'
      })
    },
    isActionWithBatchAllowed (action) {
      return !formsCache[action.preferences.form_id]?.preferences?.default_values_api_path
    },
    removeRequest (resource) {
      return api.delete(`data/${this.model.slug}/${resource[this.model.primary_key]}`)
    },
    applyAction (action) {
      if (action.name === 'edit' && action.action_type === 'default') {
        return this.edit()
      }

      if (action.name === 'remove' && action.action_type === 'default') {
        return this.remove()
      }

      if (action.action_type === 'form' && this.resources.length > 1 && !this.isActionWithBatchAllowed(action)) {
        return
      }

      if (action.action_type === 'method') {
        return Promise.all(this.resources.map((resource) => {
          return this.methodRequest(resource, action)
        })).then((result) => {
          this.$Message.info(this.i18n.action_has_been_applied)
        }).catch((error) => {
          this.onApiError(error)
        }).finally(() => {
          this.$emit('finish-action', action.name)
        })
      }

      loadFormFromCache(action.preferences.form_id).then((form) => {
        if (!form) {
          return this.$Message.warning(this.i18n.action_has_been_removed)
        }

        if (form.preferences.fields.length === 1) {
          if (action.preferences.with_confirm) {
            this.$Dialog.confirm({
              title: this.i18n.are_you_sure,
              closable: true,
              onOk: () => {
                this.applyRequest(action, form)
              }
            })
          } else {
            this.applyRequest(action, form)
          }
        } else {
          return this.openForm(this.resources, form, action)
        }
      })
    },
    applyRequest (action, form) {
      this.$emit('start-action', action.name)

      return Promise.all(this.resources.map((resource) => {
        return this.apiRequest(resource, form)
      })).then((result) => {
        const blob = result[0].data

        blob.text().then(text => {
          try {
            result[0].data = JSON.parse(text)
          } catch (e) {
            result[0].data = text
          }

          if (result[0].data?.errors) {
            this.$Message.error(truncate(result.data.errors.map(e => e.message).join('\n'), 70))
          } else {
            if (result.length === 1) {
              const resultData = result[0].data
              const redirectTo = resultData?.data?.redirect || resultData?.data?.redirect_to || resultData?.redirect || resultData?.redirect_to

              if (typeof redirectTo === 'string') {
                this.redirectTo(redirectTo)
              } else if (result[0].headers['content-disposition']?.startsWith('attachment')) {
                const fileName = result[0].headers['content-disposition'].match(/filename="(.*?)"/)?.[1]
                const dataUrl = URL.createObjectURL(blob)

                const link = document.createElement('a')

                link.setAttribute('href', dataUrl)
                link.setAttribute('download', `${fileName || 'attachment'}`)

                link.click()
              } else if (typeof resultData === 'string') {
                this.$Dialog.success({ title: this.i18n.action_has_been_applied, content: resultData })
              } else {
                this.$Message.info(this.i18n.action_has_been_applied)
              }
            } else {
              this.$Message.info(this.i18n.action_has_been_applied)
            }
          }
        })
      }).catch((error) => {
        this.onApiError(error)
      }).finally(() => {
        this.$emit('finish-action', action.name)
      })
    },
    onApiError (error) {
      error.response.data.text().then(text => {
        try {
          error.response.data = JSON.parse(text)
        } catch (e) {
          error.response.data = text
        }
        if (error.response?.data?.errors) {
          this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
        } else if (error?.response?.status) {
          this.$Message.error(`${this.i18n.action_has_failed_with_code} ${error.response.status}`)
        } else {
          this.$Message.error(error.message)
        }
      })
    },
    redirectTo (redirectTo) {
      const resolvedRoute = this.$router.resolve({ path: redirectTo.replace(location.origin, '') }, this.$route)

      if (resolvedRoute?.name) {
        this.$router.push(resolvedRoute)

        this.$Message.info(this.i18n.action_has_been_applied)
      } else {
        location.href = redirectTo
      }
    },
    apiRequest (resource, form) {
      const params = {
        [this.model.name + '_' + this.model.primary_key]: resource[this.model.primary_key],
        ...resource
      }

      const path = interpolate(form.api_path, params)

      if (form.api_config_name !== 'origin') {
        if (form.preferences.request_type === 'graphql') {
          return api.post('run_graphql_request', {
            data: {
              query: form.preferences.graphql_mutation,
              api_config_name: form.api_config_name,
              variables: params
            }
          }, {
            responseType: 'blob'
          })
        } else {
          return api.post('run_api_request', {
            data: {
              method: form.http_method,
              body: params,
              api_config_name: form.api_config_name,
              path
            }
          }, {
            responseType: 'blob'
          })
        }
      } else {
        return loadCredentials().then((credentials) => {
          return axios[form.http_method.toLowerCase()](path, {
            ...params
          }, {
            responseType: 'blob',
            headers: {
              ...this.requestHeaders,
              ...credentials.headers
            }
          })
        })
      }
    },
    openForm (resources, form, action) {
      const data = resources.length === 1 ? resources[0] : {}

      this.$Drawer.open(CustomFormWrapper, {
        data,
        withFooterSubmit: true,
        form,
        triggerRequest: resources.length === 1,
        excludeFields: ['id', `${this.model.name}_${this.model.primary_key}`],
        onSuccess: (data) => {
          this.$emit('finish-action', action.name)
        },
        onSubmitData: (data) => {
          Promise.all(resources.map((resource) => {
            return this.apiRequest(resource, form)
          })).then((result) => {
            this.$Message.info(this.i18n.action_has_been_applied)
          }).catch((error) => {
            this.onApiError(error)
          }).finally(() => {
            this.$emit('finish-action', action.name)

            this.$Drawer.remove()
          })
        }
      }, {
        slots: {
          header: () => h(FormHeader, { resource: data, resourceName: this.resourceName, action: action.name })
        },
        handleClickOutside () {
          if (this.$el.querySelector('form[data-form-edited="true"]')) {
            this.$Dialog.confirm({
              title: this.i18n.there_are_unsaved_changes_close_form,
              closable: true,
              onOk: () => {
                this.close()
              }
            })
          } else {
            this.close()
          }
        },
        closable: true
      })
    },
    edit () {
      if (this.resources.length !== 1) {
        return
      }

      const resourceTitle = `${singularize(this.model.display_name)} #${this.resource[this.model.primary_key]}`

      this.$Drawer.open(ResourceForm, {
        resource: this.resource,
        action: 'edit',
        resourceName: this.resourceName,
        onClose: () => {
          this.$Drawer.remove()
        },
        onSuccess: (data) => {
          this.$Message.info(`${resourceTitle} ${this.i18n.has_been_updated}`)
          this.$emit('finish-action', 'edit')
        }
      }, {
        slots: {
          header: () => h(FormHeader, { resource: this.resource, resourceName: this.resourceName, action: 'edit' })
        },
        handleClickOutside () {
          if (this.$el.querySelector('form[data-form-edited="true"]')) {
            this.$Dialog.confirm({
              title: this.i18n.there_are_unsaved_changes_close_form,
              closable: true,
              onOk: () => {
                this.close()
              }
            })
          } else {
            this.close()
          }
        },
        className: 'drawer-no-bottom-padding',
        closable: true
      })
    },
    onDropdownVisibleChange (value) {
      if (value) {
        loadFormsToCache(this.permittedActions.map((a) => a.preferences.form_id))
      }
    },
    remove () {
      this.$Dialog.confirm({
        title: (
          this.resources.length > 1
            ? [this.i18n.items_will_be_removed.replace('%{count}', this.resources.length), this.i18n.are_you_sure].join('. ')
            : [this.i18n.selected_item_will_be_removed, this.i18n.are_you_sure].join('. ')
        ),
        closable: true,
        onOk: () => {
          this.$emit('start-action', 'remove')

          Promise.all(this.resources.map(this.removeRequest)).then((result) => {
            if (this.resources.length > 1) {
              this.$Message.info(`${this.resources.length} ${this.i18n.items_have_been_removed}`)
            } else {
              this.$Message.info(this.i18n.selected_item_has_been_removed)
            }
          }).catch((error) => {
            console.error(error)

            if (error.response.data?.errors) {
              this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
            } else {
              this.$Message.error(this.i18n.unable_to_remove_items)
            }
          }).finally(() => {
            this.$emit('finish-action', 'remove')
          })
        }
      })
    }
  }
}
</script>

<style lang="scss">
</style>
