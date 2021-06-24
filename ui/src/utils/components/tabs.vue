<template>
  <div class="ivu-tabs">
    <div class="ivu-tabs-bar">
      <div
        tabindex="0"
        class="ivu-tabs-nav-container"
      >
        <div
          class="ivu-tabs-nav-wrap"
          style="position: relative;"
        >
          <div class="ivu-tabs-scroll">
            <div
              class="ivu-tabs-nav"
              :class="`text-${position} w-100`"
            >
              <component
                :is="tab.to ? 'RouterLink' : 'div'"
                v-for="tab in tabs"
                :ref="setTabRef"
                :key="tab.value"
                :class="tab.value === currentTab ? 'ivu-tabs-tab-focused ivu-tabs-tab-active' : ''"
                class="ivu-tabs-tab"
                :to="tab.to"
                @click="onTabClick(tab)"
              >
                {{ tab.label }}
              </component>
            </div>
          </div>
        </div>
      </div>
    </div>
    <slot />
  </div>
</template>

<script>
export default {
  name: 'SimpleTabs',
  props: {
    tabs: {
      type: Array,
      required: true
    },
    position: {
      type: String,
      required: false,
      default: 'start'
    },
    modelValue: {
      type: String,
      required: false,
      default: ''
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      currentTab: '',
      tabRefs: []
    }
  },
  watch: {
    modelValue (value) {
      this.currentTab = value
    }
  },
  mounted () {
    this.currentTab = this.modelValue || this.tabs[0]?.value
  },
  beforeUpdate () {
    this.tabRefs = []
  },
  methods: {
    setTabRef (el) {
      if (el) {
        this.tabRefs.push(el)
      }
    },
    onTabClick (tab) {
      if (tab.value) {
        this.currentTab = tab.value
        this.$emit('update:modelValue', tab.value)
      }

      const index = this.tabs.indexOf(tab)
      const tabRef = this.tabRefs[index + 1] || this.tabRefs[index]
      const el = tabRef?.$el || tabRef

      el?.scrollIntoView({ inline: 'end', block: 'start', behavior: 'smooth' })
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.ivu-tabs-tab {
  padding: 8px 32px;
  margin: 0;

  @media screen and (max-width: $breakpoint-md) {
    padding: 8px 18px;
  }
}

a.ivu-tabs-tab {
  color: inherit;
}

.ivu-tabs-tab-active {
  border-bottom: 3px solid $primary-color;
}

.ivu-tabs-tab {
  user-select: none;
}

.ivu-tabs-scroll {
  overflow-x: auto;

  &::-webkit-scrollbar {
    display: none;
  }
}
</style>
