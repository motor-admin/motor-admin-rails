<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataLink"
      @submit.prevent="submit"
    >
      <FormItem
        :label="i18n['name']"
        prop="name"
      >
        <VInput
          v-model="dataLink.name"
          :placeholder="i18n['link_name']"
          @keydown.enter="submit"
        />
      </FormItem>
      <FormItem
        v-if="!['forms', 'reports'].includes(dataLink.link_type)"
        :label="i18n['path']"
        prop="path"
      >
        <VInput
          v-model="dataLink.path"
          placeholder="/path"
          @keydown.enter="submit"
        />
      </FormItem>
      <FormItem
        v-if="!['forms', 'reports'].includes(dataLink.link_type)"
        :label="i18n['type']"
        prop="type"
      >
        <MSelect
          v-model="dataLink.link_type"
          :options="linkTypeOptions"
        />
      </FormItem>
    </VForm>
    <Checkbox
      :model-value="!!dataLink.conditions.length"
      class="d-block mb-3"
      @update:model-value="toggleConditions"
    >
      {{ ' ' }} {{ i18n['conditional'] }}
    </Checkbox>
    <div
      v-for="(item, index) in dataLink.conditions"
      :key="index"
      class="d-flex justify-content-between mt-2"
    >
      <MSelect
        v-model="item.field"
        style="width: 45%"
        :placeholder="i18n.field"
        :options="['role', 'email']"
        :with-deselect="false"
      />
      <MSelect
        v-model="item.value"
        multiple
        allow-create
        style="width: 45%"
        :placeholder="i18n.value"
      />
      <VButton
        icon="md-close"
        type="text"
        @click="dataLink.conditions.splice(index, 1)"
      />
    </div>
    <VButton
      v-if="!!dataLink.conditions.length"
      :icon="'md-add'"
      type="text"
      class="bg-transparent"
      long
      @click="dataLink.conditions.push({ field: 'role', value: ''})"
    >
      {{ i18n.add_condition }}
    </VButton>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove', link)"
        >
          {{ i18n['remove'] }}
        </VButton>
        <VButton
          @click="$emit('cancel')"
        >
          {{ i18n['cancel'] }}
        </VButton>
      </div>
      <VButton
        type="primary"
        :loading="isLoading"
        @click="submit"
      >
        {{ submitText }}
      </VButton>
    </div>
  </div>
</template>

<script>
import { i18nDict, fieldRequiredMessage } from 'utils/scripts/i18n'

export default {
  name: 'LinkForm',
  props: {
    link: {
      type: Object,
      required: true
    },
    submitText: {
      type: String,
      required: false,
      default: i18nDict.save
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['cancel', 'submit', 'remove'],
  data () {
    return {
      isLoading: false,
      dataLink: {
        conditions: [],
        type: 'header',
        ...this.link
      }
    }
  },
  computed: {
    linkTypeOptions () {
      return [
        { label: this.i18n.header, value: 'header' },
        { label: this.i18n.user_dropdown, value: 'user_dropdown' }
      ]
    },
    rules () {
      return {
        name: [{ required: true, message: fieldRequiredMessage('name') }],
        path: [{ required: true, message: fieldRequiredMessage('path') }]
      }
    }
  },
  methods: {
    toggleConditions (value) {
      if (this.dataLink.conditions.length) {
        this.dataLink.conditions = []
      } else {
        this.dataLink.conditions = [{ field: 'role', value: [] }]
      }
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.$emit('submit', [this.link, this.dataLink])
        }
      })
    }
  }
}
</script>
