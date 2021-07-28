<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataItem"
      @submit.prevent="submit"
    >
      <FormItem
        ref="titleInput"
        :label="i18n['title']"
        prop="display_name"
      >
        <VInput
          v-model="dataItem.display_name"
          :placeholder="i18n['field_name']"
          @drag.stop
        />
      </FormItem>
      <FormItem
        :label="i18n['markdown']"
        prop="markdown"
      >
        <VInput
          v-model="dataItem.markdown"
          type="textarea"
          :autosize="{ minRows: 4, maxRows: 5 }"
          @drag.stop
        />
        <div class="text-center">
          <VButton
            type="text"
            icon="logo-markdown"
            @click="openMarkdownEditor"
          >
            Open in markdown editor
          </VButton>
        </div>
      </FormItem>
      <Checkbox
        :model-value="isConditional"
        class="d-block mb-3"
        @update:model-value="toggleConditional"
      >
        {{ ' ' }} {{ i18n['conditional'] }}
      </Checkbox>
      <FieldCondition
        v-if="isConditional"
        v-model="dataItem.conditions[0]"
        :fields="conditionFields"
      />
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove')"
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
        @click="submit"
      >
        {{ okText }}
      </VButton>
    </div>
  </div>
</template>

<script>
import { underscore } from 'utils/scripts/string'
import { i18nDict, fieldRequiredMessage } from 'utils/scripts/i18n'
import FieldCondition from './editor_field_condition'
import MarkdownForm from './editor_markdown_form'

export default {
  name: 'TextForm',
  components: {
    FieldCondition
  },
  props: {
    item: {
      type: Object,
      required: true
    },
    okText: {
      type: String,
      required: false,
      default: i18nDict.ok
    },
    focus: {
      type: Boolean,
      required: false,
      default: false
    },
    conditionFields: {
      type: Array,
      required: false,
      default: () => []
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'remove', 'cancel'],
  data () {
    return {
      dataItem: {}
    }
  },
  computed: {
    rules () {
      return {
        display_name: [{
          required: true,
          message: fieldRequiredMessage('title')
        }],
        markdown: [{
          required: true,
          message: fieldRequiredMessage('markdown')
        }]
      }
    },
    isConditional () {
      return !!this.dataItem.conditions?.length
    }
  },
  mounted () {
    if (this.focus) {
      this.$refs.titleInput.$el.querySelector('input').focus()
    }
  },
  created () {
    this.dataItem = JSON.parse(JSON.stringify(this.item))
  },
  methods: {
    openMarkdownEditor () {
      this.$Modal.open(MarkdownForm, {
        modelValue: this.dataItem.markdown,
        fields: this.conditionFields.map((f) => ({ name: f.value })),
        onSubmit: (value) => {
          this.dataItem.markdown = value

          this.$Modal.remove()
        }
      }, {
        title: this.i18n.edit_markdown,
        closable: true
      })
    },
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          this.dataItem.name = underscore(this.dataItem.display_name)

          if (this.dataItem.conditions && !this.dataItem.conditions[0]?.field) {
            this.dataItem.conditions = []
          }

          this.$emit('submit', this.dataItem)
        }
      })
    },
    toggleConditional () {
      this.dataItem.conditions ||= []

      if (this.isConditional) {
        this.dataItem.conditions = []
      } else {
        this.dataItem.conditions = [{ field: '', action: 'eq', value: '' }]
      }
    }
  }
}
</script>
