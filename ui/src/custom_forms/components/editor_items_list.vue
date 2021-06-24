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
      <FieldItem
        v-if="item.field_type"
        :field="item"
        class="mb-2"
        @remove="removeItem"
        @replace="replaceItem"
      />
      <GroupItem
        v-if="Array.isArray(item.items)"
        :group="item"
        class="mb-2"
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
      ok-text="Add"
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
      ok-text="Add"
      @submit="addGroup"
      @cancel="newGroup = null"
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
      Add Field
    </VButton>

    <VButton
      long
      type="text"
      icon="md-add"
      class="ms-1"
      @click="toggleNewGroup"
    >
      Add Group
    </VButton>
  </div>
</template>

<script>
import GroupForm from './editor_group_form'
import FieldForm from './editor_field_form'
import FieldItem from './editor_field_item'
import GroupItem from './editor_group_item'

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

export default {
  name: 'LayoutItemsList',
  components: {
    GroupForm,
    FieldForm,
    FieldItem,
    GroupItem
  },
  props: {
    items: {
      type: Array,
      required: false,
      default: () => ([])
    },
    withButtons: {
      type: Boolean,
      required: false,
      default: true
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
      newGroup: null
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
