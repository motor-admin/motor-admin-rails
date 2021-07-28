<template>
  <VueDraggableNext
    :list="items"
    handle=".handle"
    group="form"
    :style="withMinHeight ? 'min-height: 15px' : null"
  >
    <div
      v-for="item in items"
      :key="item.name"
    >
      <TextItem
        v-if="item.markdown"
        :item="item"
        class="mb-2"
        :condition-fields="listConditionFieldOptions"
        @remove="removeItem"
        @replace="replaceItem"
      />
      <FieldItem
        v-if="item.field_type"
        :field="item"
        class="mb-2"
        :condition-fields="listConditionFieldOptions"
        @remove="removeItem"
        @replace="replaceItem"
      />
      <GroupItem
        v-if="Array.isArray(item.items)"
        :group="item"
        class="mb-2"
        :nesting-level="nestingLevel + 1"
        :condition-fields="listConditionFieldOptions"
        @remove="removeItem"
        @replace="replaceItem"
      />
    </div>
  </VueDraggableNext>
  <Card
    v-if="newField"
    ref="newFieldForm"
    class="mb-2"
  >
    <FieldForm
      :field="newField"
      :focus="true"
      :ok-text="i18n['add']"
      :condition-fields="listConditionFieldOptions"
      @submit="addField"
      @cancel="newField = null"
    />
  </Card>
  <Card
    v-if="newGroup"
    ref="newGroupForm"
    class="mb-2"
  >
    <GroupForm
      :group="newGroup"
      :focus="true"
      :ok-text="i18n['add']"
      :condition-fields="listConditionFieldOptions"
      @submit="addGroup"
      @cancel="newGroup = null"
    />
  </Card>
  <Card
    v-if="newTextItem"
    ref="newTextForm"
    class="mb-2"
  >
    <TextForm
      :item="newTextItem"
      :condition-fields="listConditionFieldOptions"
      :focus="true"
      :ok-text="i18n['add']"
      @submit="addTextItem"
      @cancel="newTextItem = null"
    />
  </Card>

  <div
    v-if="withButtons"
    class="d-flex my-2"
  >
    <VButton
      long
      type="text"
      icon="md-add"
      class="me-1"
      @click="toggleNewField"
    >
      {{ i18n['add_field'] }}
    </VButton>

    <VButton
      v-if="nestingLevel < 3"
      long
      type="text"
      icon="md-add"
      class="ms-1"
      @click="toggleNewGroup"
    >
      {{ i18n['add_group'] }}
    </VButton>
    <Dropdown
      trigger="click"
      class="ms-1 text-start float-end"
      :placement="'bottom-end'"
      style="position: absolute; bottom: 7px; right: 0px"
    >
      <VButton
        long
        type="text"
        icon="md-more"
      />
      <template #list>
        <DropdownMenu>
          <DropdownItem
            v-if="nestingLevel >= 3"
            @click="toggleNewGroup"
          >
            {{ i18n['add_group'] }}
          </DropdownItem>
          <DropdownItem @click="toggleNewTextItem">
            {{ i18n['add_text'] }}
          </DropdownItem>
        </DropdownMenu>
      </template>
    </Dropdown>
  </div>
</template>

<script>
import GroupForm from './editor_group_form'
import FieldForm from './editor_field_form'
import FieldItem from './editor_field_item'
import GroupItem from './editor_group_item'
import TextItem from './editor_text_item'
import TextForm from './editor_text_form'

const defaultFieldParams = {
  display_name: '',
  name: '',
  field_type: 'input',
  default_value: '',
  validators: []
}

const defaultGroupParams = {
  display_name: '',
  name: '',
  items: []
}

const defaultTextItemParams = {
  display_name: '',
  name: '',
  markdown: ''
}

export default {
  name: 'LayoutItemsList',
  components: {
    GroupForm,
    FieldForm,
    FieldItem,
    GroupItem,
    TextItem,
    TextForm
  },
  props: {
    items: {
      type: Array,
      required: false,
      default: () => []
    },
    withButtons: {
      type: Boolean,
      required: false,
      default: true
    },
    nestingLevel: {
      type: Number,
      required: false,
      default: 0
    },
    conditionFields: {
      type: Array,
      required: false,
      default: () => []
    },
    withMinHeight: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data () {
    return {
      newField: null,
      newGroup: null,
      newTextItem: null
    }
  },
  computed: {
    fieldItems () {
      return this.items.filter((e) => e.field_type)
    },
    listConditionFieldOptions () {
      return [
        ...this.items.map((item) => {
          if (item.field_type) {
            return { label: item.display_name, value: item.name, field: item }
          } else {
            return false
          }
        }).filter(Boolean),
        ...this.conditionFields
      ]
    }
  },
  methods: {
    toggleNewField () {
      if (this.newField) {
        this.newField = null
      } else {
        this.newField = JSON.parse(JSON.stringify(defaultFieldParams))

        this.$nextTick(() => {
          this.$refs.newFieldForm.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    toggleNewTextItem () {
      if (this.newTextItem) {
        this.newTextItem = null
      } else {
        this.newTextItem = { ...defaultTextItemParams }

        this.$nextTick(() => {
          this.$refs.newTextForm.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    toggleNewGroup () {
      if (this.newGroup) {
        this.newGroup = null
      } else {
        this.newGroup = JSON.parse(JSON.stringify(defaultGroupParams))

        this.$nextTick(() => {
          this.$refs.newGroupForm.$el.scrollIntoView({ inline: 'end', block: 'center', behavior: 'smooth' })
        })
      }
    },
    addField (field) {
      this.items.push(field)

      this.newField = null
    },
    addTextItem (item) {
      this.items.push(item)

      this.newTextItem = null
    },
    addGroup (group) {
      this.items.push(group)

      this.newGroup = null
    },
    removeItem (item) {
      const index = this.items.indexOf(item)

      this.items.splice(index, 1)
    },
    replaceItem ([oldItem, newItem]) {
      const index = this.items.indexOf(oldItem)

      this.items.splice(index, 1, newItem)
    }
  }
}
</script>
