<template>
  <div
    v-click-outside="closeDropdown"
    class="ivu-select"
    :class="{
      'ivu-select-visible': isOpen,
      [`ivu-select-${size}`]: true,
      'ivu-select-multiple': multiple,
      'ivu-select-single': !multiple
    }"
    @keydown.enter.stop="applyFocused"
    @keydown.up.prevent="moveFocus(-1)"
    @keydown.down.prevent="moveFocus(1)"
  >
    <div
      ref="selection"
      tabindex="-1"
      :class="border ? 'ivu-select-selection' : 'ivu-select-no-border'"
      @click="toggleDropdown"
    >
      <div>
        <div
          v-for="option in selectedOptions"
          :key="getValue(option)"
          class="ivu-tag ivu-tag-checked"
        >
          <span class="ivu-tag-text">{{ getLabel(option) }}</span>
          <i
            class="ion ion-ios-close"
            @click.stop="removeOption(option)"
          />
        </div>
        <input
          v-if="remoteFunction || filterable"
          ref="input"
          v-model="searchInput"
          type="text"
          :placeholder="selectedOptions.length ? '' : placeholder"
          autocomplete="off"
          spellcheck="false"
          class="ivu-select-input"
          :class="{ 'ivu-input-no-border': !border }"
          @keydown.down="isOpen = true"
          @keydown.up="isOpen = true"
          @keydown.tab.prevent="onTabKey"
          @keydown.backspace="maybeRemoveOption"
          @input="onSearch"
        >
        <span
          v-else
          class="ivu-select-selected-value"
        >
          {{ getLabel(selectedOption) }}
        </span>
        <i
          class="ivu-select-icon"
          :class="icon ? `ion ion-${icon} ivu-select-custom-icon` : `ion ion-ios-arrow-down ivu-select-arrow`"
        />
      </div>
    </div>
    <transition name="transition-drop">
      <div
        v-show="isOpen && (optionsData.length || displayCreate || notFound)"
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
            v-if="displayCreate"
            class="ivu-select-item"
            :class="{'ivu-select-item-focus': focusIndex === 0}"
            @click.stop="createOption(searchInput)"
          >
            {{ searchInput }}
            <i class="ion ion-md-return-left ivu-select-item-enter" />
          </li>
          <li
            v-for="(option, index) in optionsToRender"
            :key="index"
            :ref="setOptionRef"
            class="ivu-select-item"
            :class="[isSelected(option) ? 'ivu-select-item-selected ivu-select-item-focus' : '', focusIndex === (displayCreate ? index + 1 : index) ? 'ivu-select-item-focus' : '']"
            @click.stop="selectOption(option)"
          >
            <component
              :is="optionComponent"
              v-if="optionComponent"
              :option="option"
            />
            <template v-else>
              {{ getLabel(option) }}
            </template>
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
import throttle from 'view3/src/utils/throttle'
import Popper from 'popper.js/dist/umd/popper.js'

export default {
  name: 'SimpleSelect',
  directives: { clickOutside },
  props: {
    modelValue: {
      type: [String, Number, Array, Boolean],
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
    icon: {
      type: String,
      reqired: false,
      default: null
    },
    filterable: {
      type: Boolean,
      required: false,
      default: false
    },
    multiple: {
      type: Boolean,
      required: false,
      default: false
    },
    allowCreate: {
      type: Boolean,
      required: false,
      default: false
    },
    createFunction: {
      type: Function,
      required: false,
      default: (value) => {
        return Promise.resolve({ value, label: value })
      }
    },
    border: {
      type: Boolean,
      required: false,
      default: true
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
    valueFunction: {
      type: Function,
      required: false,
      default: null
    },
    focusFirst: {
      type: Boolean,
      required: false,
      default: false
    },
    optionComponent: {
      type: Object,
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
  emits: ['update:modelValue', 'search', 'select'],
  data () {
    return {
      isLoading: false,
      optionsData: [],
      optionRefs: [],
      popper: null,
      selectedOption: null,
      selectedOptions: [],
      focusIndex: -1,
      searchInput: '',
      isOptionsLoaded: false,
      isOpen: false
    }
  },
  computed: {
    displayCreate () {
      return this.searchInput && this.allowCreate && !this.optionsToRender.find((opt) => this.getValue(opt) === this.searchInput)
    },
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
          return this.getLabel(option).toLowerCase().includes(this.searchInput.toLowerCase())
        })
      } else {
        return this.optionsData
      }
    },
    notFound () {
      return !this.allowCreate && this.withFilter && ((this.remoteFunction ? !!this.searchInput : true) && this.optionsToRender.length === 0)
    }
  },
  watch: {
    isOptionsLoaded () {
      this.assignSelectedFromValue(this.modelValue)

      this.searchInput = this.getLabel(this.selectedOption)
    },
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
    options: {
      deep: true,
      handler (value) {
        this.optionsData = this.normalizeOptions(value)
        this.assignSelectedFromValue(this.modelValue)

        if (this.optionsData.length) {
          this.isOptionsLoaded = true
        }
      }
    },
    isOpen (value) {
      if (value) {
        this.$refs.dropdown.style.minWidth = getStyle(this.$el, 'width')
      }
    }
  },
  mounted () {
    if (this.remoteFunction) {
      this.remoteFunction(this.modelValue)
    } else {
      this.optionsData = this.normalizeOptions(this.options)
      this.assignSelectedFromValue(this.modelValue)

      if (!this.multiple) {
        this.searchInput = this.getLabel(this.selectedOption) || this.modelValue
      }
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
    createOption (value) {
      this.createFunction(value).then((option) => {
        this.optionsData.unshift(option)
        this.selectOption(option)
      })
    },
    onTabKey () {
      if (this.displayCreate && this.focusIndex === 0) {
        this.createOption(this.searchInput)
      } else {
        const label = this.getLabel(this.optionsToRender[this.focusIndex])

        if (label) {
          this.searchInput = label
          this.onSearch()
        }
      }
    },
    normalizeOptions () {
      if (this.options.length === 0) {
        return []
      } else if (['string', 'number', 'boolean'].includes(typeof this.options[0])) {
        return this.options.map(option => {
          return { value: option, label: option.toString() }
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
    getValue (option) {
      if (option) {
        return this.valueFunction ? this.valueFunction(option) : option[this.valueKey]
      } else {
        return ''
      }
    },
    onSearch () {
      this.remoteFunction && this.remoteFunction(this.searchInput)
      const index = this.optionsToRender.indexOf(this.selectedOption)
      this.focusIndex = index === -1 ? 0 : index
      this.isOpen = true
      this.popper?.update()
      this.$emit('search', this.searchInput)
    },
    moveFocus: throttle(function (index) {
      const maxLength = this.displayCreate ? (this.optionsToRender.length + 1) : this.optionsToRender.length
      const nextIndex = this.focusIndex + index
      if (nextIndex >= maxLength) {
        this.focusIndex = 0
      } else if (nextIndex < 0) {
        this.focusIndex = maxLength - 1
      } else {
        this.focusIndex += index
      }

      this.$nextTick(() => {
        this.optionRefs[this.focusIndex]?.scrollIntoView({ block: 'nearest' })
      })
    }, 80),
    applyFocused () {
      if (this.displayCreate && this.focusIndex === 0) {
        this.createOption(this.searchInput)

        this.toggleDropdown()
      } else {
        const index = this.displayCreate ? this.focusIndex + 1 : this.focusIndex
        const option = this.optionsToRender[index]

        if (option) {
          this.selectOption(option)
        }
      }
    },
    assignSelectedFromValue (value) {
      if (this.multiple) {
        this.selectedOptions = this.optionsData.filter((option) => {
          return !!value.find((val) => this.getValue(option).toString() === (val ?? '').toString())
        })
      } else {
        this.selectedOption = this.optionsData.find((option) => this.getValue(option).toString() === (value ?? '').toString())

        const index = this.optionsToRender.indexOf(this.selectedOption)

        this.focusIndex = this.focusFirst && index === -1 ? 0 : index
      }
    },
    isSelected (option) {
      const hasSelected = this.getValue(option) && (this.selectedOption || this.selectedOptions.length)

      if (hasSelected) {
        return (this.multiple ? this.selectedOptions : [this.selectedOption]).find((opt) => this.getValue(opt) === this.getValue(option))
      } else {
        return false
      }
    },
    selectOption (option) {
      if (this.multiple) {
        const existingOption = this.selectedOptions.find((opt) => this.getValue(opt) === this.getValue(option))

        if (existingOption) {
          this.selectedOptions.splice(this.selectedOptions.indexOf(existingOption), 1)
        } else {
          this.selectedOptions.push(option)
        }

        this.searchInput = ''

        this.$emit('update:modelValue', this.selectedOptions.map(this.getValue))
        this.$emit('select', this.selectedOptions)

        this.focusIndex = this.optionsToRender.indexOf(option)

        this.popper?.update()
        this.$refs.input?.focus()
      } else {
        this.selectedOption = option
        this.searchInput = this.getLabel(option)
        this.focusIndex = this.optionsToRender.indexOf(option)
        this.$emit('update:modelValue', this.getValue(option))
        this.$emit('select', this.selectedOption)

        this.closeDropdown()
      }
    },
    removeOption (option) {
      this.selectedOptions.splice(this.selectedOptions.indexOf(option), 1)

      this.$emit('update:modelValue', this.selectedOptions.map(this.getValue))
      this.$emit('select', this.selectedOptions)
    },
    maybeRemoveOption () {
      if (this.multiple && this.searchInput === '') {
        this.removeOption(this.selectedOptions[this.selectedOptions.length - 1])
      }
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
        placement: 'bottom-start',
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
      this.$refs.input?.focus()
    }
  }
}
</script>

<style lang="scss" scoped>
.ivu-select-custom-icon {
  position: absolute;
  right: 8px;
  top: 50%;
  color: #808695;
  font-size: 18px;
  line-height: 1;
  transform: translateY(-50%);
}

.ivu-select-no-border {
  position: relative;
  height: 40px;
}

.ivu-select-input {
  cursor: initial;
}
</style>
