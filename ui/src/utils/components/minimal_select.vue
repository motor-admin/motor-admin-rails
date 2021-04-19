<template>
  <div
    v-click-outside="closeDropdown"
    class="ivu-select ivu-select-single"
    :class="{ 'ivu-select-visible': isOpen, [`ivu-select-${size}`]: true }"
    @keydown.enter.stop="applyFocused"
    @keydown.up.prevent="moveFocus(-1)"
    @keydown.down.prevent="moveFocus(1)"
  >
    <div
      ref="selection"
      tabindex="-1"
      class="ivu-select-selection"
    >
      <div class="">
        <input
          v-if="remoteFunction || filterable"
          v-model="searchInput"
          type="text"
          :placeholder="placeholder"
          autocomplete="off"
          spellcheck="false"
          class="ivu-select-input"
          @keydown.down="isOpen = true"
          @keydown.up="isOpen = true"
          @click="toggleDropdown"
          @input="onSearch"
        >
        <span
          v-else
          class="ivu-select-selected-value"
          @click="toggleDropdown"
        >
          {{ getLabel(selectedOption) }}
        </span>
        <i
          :class="`ion ion-ios-arrow-down ivu-select-arrow`"
          @click="toggleDropdown"
        />
      </div>
    </div>
    <transition name="transition-drop">
      <div
        v-show="isOpen"
        ref="dropdown"
        class="ivu-select-dropdown"
      >
        <ul
          v-show="notFound"
          class="ivu-select-not-found"
        >
          <li>No Results</li>
        </ul>
        <ul class="ivu-select-dropdown-list">
          <li
            v-for="(option, index) in optionsToRender"
            :key="option[valueKey]"
            :ref="setOptionRef"
            class="ivu-select-item"
            :class="[isSelected(option) ? 'ivu-select-item-selected ivu-select-item-focus' : '', focusIndex === index ? 'ivu-select-item-focus' : '']"
            @click.stop="selectOption(option)"
          >
            {{ getLabel(option) }}
          </li>
        </ul>
        <ul
          v-show="isLoading"
          class="ivu-select-loading"
        >
          Loading...
        </ul>
      </div>
    </transition>
  </div>
</template>

<script>
import { directive as clickOutside } from 'view3/src/directives/v-click-outside-x'
import { getStyle } from 'view3/src/utils/assist'
import Popper from 'popper.js/dist/umd/popper.js'

export default {
  name: 'SimpleSelect',
  directives: { clickOutside },
  props: {
    modelValue: {
      type: [String, Number],
      reqired: false,
      default: ''
    },
    options: {
      type: Array,
      required: false,
      default: () => []
    },
    size: {
      type: String,
      reqired: false,
      default: 'default'
    },
    filterable: {
      type: Boolean,
      required: false,
      default: false
    },
    placeholder: {
      type: String,
      reqired: false,
      default: 'Select'
    },
    labelKey: {
      type: String,
      reqired: false,
      default: 'label'
    },
    labelFunction: {
      type: Function,
      required: false,
      default: null
    },
    valueKey: {
      type: String,
      reqired: false,
      default: 'value'
    },
    remoteFunction: {
      type: Function,
      required: false,
      default: null
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      isLoading: false,
      optionsData: [],
      optionRefs: [],
      popper: null,
      selectedOption: null,
      focusIndex: -1,
      searchInput: '',
      isOpen: false
    }
  },
  computed: {
    withFilter () {
      return this.remoteFunction || this.filterable
    },
    optionsToRender () {
      if (this.filterable && !this.remoteFunction) {
        return this.filteredOptions
      } else {
        return this.optionsData
      }
    },
    filteredOptions () {
      if (this.remoteFunction) return []

      if (this.searchInput && this.searchInput !== this.getLabel(this.selectedOption)) {
        return this.optionsData.filter((option) => {
          return this.getLabel(option).toLowerCase().startsWith(this.searchInput.toLowerCase())
        })
      } else {
        return this.optionsData
      }
    },
    notFound () {
      return this.withFilter && ((!this.remoteFunction && this.filteredOptions.length === 0) || this.optionsData.length === 0)
    }
  },
  watch: {
    optionsToRender (newArray, oldArray) {
      if (newArray.length !== oldArray.length) {
        this.popper?.update()
      }
    },
    modelValue (value) {
      if (this.remoteFunction) {
        this.remoteFunction(value).then(() => {
          this.assignSelectedFromValue(value)

          this.searchInput = this.getLabel(this.selectedOption)
        })
      } else {
        this.assignSelectedFromValue(value)
      }
    },
    options (value) {
      this.optionsData = this.normalizeOptions(value)
      this.assignSelectedFromValue(this.modelValue)
    },
    isOpen (value) {
      if (value) {
        this.$refs.dropdown.style.width = getStyle(this.$el, 'width')
      }
    }
  },
  mounted () {
    if (this.remoteFunction) {
      this.remoteFunction(this.modelValue).then(() => {
        this.assignSelectedFromValue(this.modelValue)

        this.searchInput = this.getLabel(this.selectedOption)
      })
    } else {
      this.optionsData = this.normalizeOptions(this.options)
      this.assignSelectedFromValue(this.modelValue)
      this.searchInput = this.getLabel(this.selectedOption) || this.modelValue
    }
  },
  beforeUpdate () {
    this.optionRefs = []
  },
  methods: {
    setOptionRef (el) {
      if (el) {
        this.optionRefs.push(el)
      }
    },
    normalizeOptions () {
      if (this.options.length === 0) {
        return []
      } else if (['string', 'number'].includes(typeof this.options[0])) {
        return this.options.map(option => {
          return { value: option, label: option }
        })
      } else {
        return [...this.options]
      }
    },
    getLabel (option) {
      if (option) {
        return this.labelFunction ? this.labelFunction(option) : option[this.labelKey]
      } else {
        return ''
      }
    },
    onSearch () {
      this.remoteFunction && this.remoteFunction(this.searchInput)
      this.focusIndex = this.optionsToRender.findIndex((option) => option.value === this.selectedOption?.value)
      this.isOpen = true
      this.popper?.update()
    },
    moveFocus (index) {
      const nextIndex = this.focusIndex + index
      if (nextIndex >= this.optionsData.length) {
        this.focusIndex = 0
      } else if (nextIndex < 0) {
        this.focusIndex = this.optionsData.length - 1
      } else {
        this.focusIndex += index
      }

      this.$nextTick(() => {
        this.optionRefs[this.focusIndex]?.scrollIntoView({ block: 'nearest' })
      })
    },
    applyFocused () {
      this.selectOption(this.optionsToRender[this.focusIndex])
    },
    assignSelectedFromValue (value) {
      this.selectedOption = this.optionsData.find((option) => (option[this.valueKey] || '').toString() === (value || '').toString())

      this.focusIndex = this.optionsToRender.indexOf(this.selectedOption)
    },
    isSelected (option) {
      return option[this.valueKey] && this.selectedOption && option[this.valueKey] === this.selectedOption[this.valueKey]
    },
    selectOption (option) {
      this.selectedOption = option
      this.searchInput = this.getLabel(option)
      this.focusIndex = this.optionsData.indexOf(option)
      this.$emit('update:modelValue', option[this.valueKey])

      this.closeDropdown()
    },
    closeDropdown () {
      this.isOpen = false

      if (this.selectedOption) {
        this.searchInput = this.getLabel(this.selectedOption)
      }
    },
    toggleDropdown () {
      this.isOpen = !this.isOpen

      this.popper ||= new Popper(this.$el, this.$refs.dropdown, {
        modifiers: {
          computeStyle: {
            gpuAcceleration: false
          },
          preventOverflow: {
            boundariesElement: 'window'
          }
        }
      })

      this.popper.update()
    }
  }
}
</script>
