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
          <div class="ivu-tabs-nav-scroll">
            <div
              class="ivu-tabs-nav"
              :class="`text-${position} w-100`"
            >
              <component
                :is="tab.to ? 'RouterLink' : 'div'"
                v-for="tab in tabs"
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
      currentTab: ''
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
  methods: {
    onTabClick (tab) {
      if (tab.value) {
        this.currentTab = tab.value
        this.$emit('update:modelValue', tab.value)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.ivu-tabs-tab {
  padding: 8px 32px;
  margin: 0;
}

a.ivu-tabs-tab {
  color: inherit;
}

.ivu-tabs-tab-active {
  border-bottom: 3px solid $primary-color;
}

.ivu-tabs-tab {
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
</style>
