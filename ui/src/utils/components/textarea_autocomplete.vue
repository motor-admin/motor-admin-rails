<template>
  <div class="autocomplete">
    <textarea
      ref="textarea"
      v-model="inputValue"
      :rows="rows"
      :cols="cols"
      class="autocomplete-input text-dark"
      :placeholder="placeholder"
      type="text"
      @focusout="focusout"
      @focus="focus"
      @keydown.enter="chooseItem"
      @keydown.tab="chooseItem"
      @keydown.arrow-down="moveDown"
      @keydown.arrow-up="moveUp"
    />
    <ul
      v-if="searchMatch.length > 0"
      ref="list"
      :class="{ 'autocomplete-list': true }"
    >
      <li
        v-for="(result, index) in searchMatch"
        :key="index"
        :ref="setItemRef"
        :class="{active: selectedIndex === index}"
        @click="selectItem(index), chooseItem()"
      >
        {{ result.label }}
      </li>
    </ul>
  </div>
</template>

<script>
import { getCaretCoordinates } from '../scripts/get_caret_coordinates'

export default {
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    items: {
      type: Array,
      required: false,
      default: () => []
    },
    itemFunctions: {
      type: Object,
      required: false,
      default: () => ({})
    },
    placeholder: {
      type: String,
      required: false,
      default: ''
    },
    rows: {
      type: Number,
      required: false,
      default: 4
    },
    cols: {
      type: Number,
      required: false,
      default: 1
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      inputValue: '',
      searchMatch: [],
      loadedItems: {},
      itemRefs: [],
      selectedIndex: 0,
      clickedChooseItem: false,
      wordIndex: 0
    }
  },
  computed: {
    listToSearch () {
      return this.items
    },
    currentWord () {
      return this.inputValue.replace(/(\r\n|\n|\r)/gm, ' ').split(' ')[this.wordIndex]
    },
    inputSplitted () {
      return this.inputValue.replace(/(\r\n|\n|\r)/gm, ' ').split(' ')
    }
  },
  watch: {
    modelValue () {
      this.inputValue = this.modelValue
    },
    inputValue () {
      this.focus()

      this.selectedIndex = 0
      this.wordIndex = this.inputSplitted.length - 1

      this.$emit('update:modelValue', this.inputValue)
    }
  },
  beforeUpdate () {
    this.itemRefs = []
  },
  mounted () {
    this.inputValue = this.modelValue

    this.$refs.textarea.addEventListener('input', () => {
      const caret = getCaretCoordinates(this.$refs.textarea, this.$refs.textarea.selectionEnd)

      if (this.searchMatch.length > 0) {
        const element = this.$refs.list

        if (element) {
          element.style.top = caret.top + 20 + 'px'
          element.style.left = caret.left + 'px'
        }
      }
    })
  },
  methods: {
    setItemRef (el) {
      if (el) {
        this.itemRefs.push(el)
      }
    },
    setWord (word) {
      const currentWords = this.inputValue.replace(/(\r\n|\n|\r)/gm, '__br__ ').split(' ')

      currentWords[this.wordIndex] = currentWords[this.wordIndex].replace(this.currentWord, word + ' ')

      this.wordIndex += 1
      this.inputValue = currentWords.join(' ').replace(/__br__\s/g, '\n')
    },
    moveDown () {
      if (this.selectedIndex < this.searchMatch.length - 1) {
        this.selectedIndex++

        this.itemRefs[this.selectedIndex]?.scrollIntoView({ block: 'nearest' })
      }
    },
    moveUp () {
      if (this.selectedIndex !== -1) {
        this.selectedIndex--

        this.itemRefs[this.selectedIndex]?.scrollIntoView({ block: 'nearest' })
      }
    },
    selectItem (index) {
      this.selectedIndex = index
    },
    chooseItem (e) {
      this.clickedChooseItem = true

      if (this.selectedIndex !== -1 && this.searchMatch.length > 0) {
        if (e) {
          e.preventDefault()
        }

        this.setWord(this.searchMatch[this.selectedIndex].value)
        this.selectedIndex = -1
      }
    },
    focusout (e) {
      setTimeout(() => {
        if (!this.clickedChooseItem) {
          this.searchMatch = []
          this.selectedIndex = -1
        }
        this.clickedChooseItem = false
      }, 100)
    },
    focus () {
      this.searchMatch = []

      if (this.currentWord !== '') {
        const loadFunction = !!this.currentWord && this.itemFunctions[this.currentWord[0]]

        if (loadFunction) {
          this.loadedItems[this.currentWord[0]] ||= loadFunction()

          this.loadedItems[this.currentWord[0]].then((result) => {
            this.searchMatch = this.currentWord.length > 1 ? result.filter(e => e.label.indexOf(this.currentWord) === 0) : result

            if (!this.searchMatch.length && this.currentWord.length > 1) {
              this.searchMatch = [{ value: this.currentWord, label: this.currentWord }]
            }
          })
        } else {
          this.searchMatch = this.listToSearch.filter(e => e.label.indexOf(this.currentWord) === 0)
        }
      }

      if (this.searchMatch.length === 1 && this.currentWord === this.searchMatch[0]) {
        this.searchMatch = []
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.autocomplete {
  position: relative;

  &-input {
    padding: 7px 10px;
    width: 100%;
    border: 1px solid #ddd;
    border-radius: 4px;
    outline: none;
  }

  &-list {
    position: absolute;
    z-index: 2;
    overflow: auto;
    min-width: 250px;
    max-height: 150px;
    margin: 0;
    margin-top: 5px;
    padding: 0;
    border: 1px solid #eee;
    list-style: none;
    border-radius: 4px;
    background-color: #fff;
    box-shadow: 0 5px 25px rgba(0, 0, 0, 0.05);

    li {
      margin: 0;
      padding: 8px 15px;

      border-bottom: 1px solid #f5f5f5;
      &:last-child {
        border-bottom: 0;
      }
      &:hover, &.active {
        background-color: #f5f5f5;
      }
    }
  }
}
</style>
