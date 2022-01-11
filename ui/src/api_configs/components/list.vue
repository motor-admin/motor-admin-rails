<template>
  <Card
    v-if="!configs.length"
    class="mb-3"
  >
    <ApiForm
      :submit-text="'Update'"
      :with-name="true"
      @submit="handleUpdate"
    />
  </Card>
  <Card
    v-for="(config, index) in configs"
    :key="index"
    class="mb-3"
  >
    <div>
      <div class="row">
        <div class="col fs-3 fw-bold">
          {{ config.name }}
        </div>
        <div class="col">
          <VButton
            v-if="config.name !== 'origin'"
            type="error"
            class="float-end"
            ghost
            icon="md-trash"
            @click="remove(config)"
          >
            {{ i18n.remove }}
          </VButton>
        </div>
      </div>
    </div>
    <VForm
      v-if="!config.showFullForm && config.name !== 'origin'"
      class="mt-3"
      :model="config"
      @submit.prevent="handleUpdate(config)"
    >
      <VInput
        v-model="config.url"
        type="text"
        placeholder="URL"
      />
      <VButton
        icon="ios-arrow-down"
        type="text"
        long
        @click="config.showFullForm = true"
      >
        {{ i18n.expand }}
      </VButton>
    </VForm>
    <ApiForm
      v-else-if="config.name !== 'origin'"
      :config="config"
      :submit-text="'Update'"
      @submit="handleUpdate"
    />
  </Card>
  <VButton
    long
    type="dashed"
    class="mb-3"
    @click="openAddApiModal"
  >
    <Icon type="md-add" />
    {{ i18n.add_api }}
  </VButton>
  <Spin
    v-if="!isLoaded"
    fix
  />
</template>

<script>
import api from 'api'

import ApiForm from '../components/form'

export default {
  name: 'ApiSettingsPage',
  components: {
    ApiForm
  },
  data () {
    return {
      isLoaded: false,
      configs: []
    }
  },
  mounted () {
    this.loadConfigs().then(() => {
      this.isLoaded = true
    })
  },
  methods: {
    loadConfigs () {
      return api.get('api_configs', {
      }).then((result) => {
        this.configs = result.data.data
      }).catch((error) => {
        console.error(error)
      })
    },
    openAddApiModal () {
      this.$Modal.open(ApiForm, {
        withName: true,
        onSubmit: (data) => {
          this.handleUpdate(data).then(() => {
            this.$Modal.remove()
          })
        }
      }, {
        title: this.i18n.add_api,
        closable: true
      })
    },
    remove (config) {
      this.$Dialog.confirm({
        title: 'Are you sure?',
        closable: true,
        onOk: () => {
          api.delete(`api_configs/${config.id}`, {
          }).then((result) => {
            this.$Message.info('API has been removed')

            this.configs.splice(this.configs.findIndex((c) => c.id === config.id), 1)
          }).catch((error) => {
            console.error(error)
          })
        }
      })
    },
    handleUpdate (config) {
      return api.post('api_configs', {
        data: { ...config }
      }).then((result) => {
        this.$Message.info('API has been updated successfuly')

        this.configs.splice(this.configs.findIndex((c) => c.id === config.id), 1, config)

        this.loadConfigs()
      }).catch((error) => {
        if (error.response?.data?.errors) {
          this.$Message.error(error.response.data.errors.join('\n'))
        } else {
          console.error(error)
        }
      })
    }
  }
}
</script>
