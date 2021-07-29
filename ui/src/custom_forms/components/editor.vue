<template>
  <div
    class="bg-white p-2"
    data-role="editor"
    style="height: calc(var(--vh, 100vh) - 135px)"
  >
    <div>
      <ItemsList
        ref="itemsList"
        :items="fields"
        :with-buttons="false"
      />
    </div>
    <div
      v-if="showFooter"
      class="sticky-footer d-flex"
    >
      <VButton
        long
        type="default"
        icon="md-add"
        class="me-1"
        @click="toggleNewField"
      >
        {{ i18n['add_field'] }}
      </VButton>

      <VButton
        long
        type="default"
        icon="md-add"
        class="ms-1"
        @click="toggleNewGroup"
      >
        {{ i18n['add_group'] }}
      </VButton>
      <Dropdown
        trigger="click"
        class="ms-1 text-start"
      >
        <VButton
          long
          type="default"
          icon="md-more"
        />
        <template #list>
          <DropdownMenu>
            <DropdownItem @click="toggleNewTextItem">
              {{ i18n['add_text'] }}
            </DropdownItem>
          </DropdownMenu>
        </template>
      </Dropdown>
    </div>
  </div>
</template>

<script>
import ItemsList from './editor_items_list'
import { watch } from 'vue'

export default {
  name: 'FormEditor',
  components: {
    ItemsList
  },
  props: {
    fields: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      showFooter: true
    }
  },
  mounted () {
    watch(
      () => !this.$refs.itemsList.newField && !this.$refs.itemsList.newGroup && !this.$refs.itemsList.newTextItem,
      (newValue) => {
        this.showFooter = newValue
      }
    )
  },
  methods: {
    toggleNewTextItem () {
      this.$refs.itemsList.toggleNewTextItem()
    },
    toggleNewField () {
      this.$refs.itemsList.toggleNewField()
    },
    toggleNewGroup () {
      this.$refs.itemsList.toggleNewGroup()
    }
  }
}
</script>
