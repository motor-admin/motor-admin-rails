<template>
  <VInput
    v-model="optionsString"
    type="textarea"
    :placeholder="i18n['options_separated_with_new_line_or_comma']"
    :autosize="{ minRows: 3, maxRows: 7 }"
    @update:modelValue="$emit('update:modelValue', optionsArray)"
  />
</template>

<script>
export default {
  name: 'OptionsSelect',
  props: {
    modelValue: {
      type: [Array, String],
      required: false,
      default: () => []
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      optionsString: ''
    }
  },
  computed: {
    optionsArray () {
      if (this.optionsString) {
        const delimiter = this.optionsString.includes('\n') ? '\n' : ','

        return this.optionsString.split(delimiter).map((e) => e.trim())
          .filter((el, i, a) => i === a.indexOf(el))
          .filter(e => !e.match(/^\s*$/))
      } else {
        return []
      }
    }
  },
  watch: {
    modelValue () {
      if (this.modelValue) {
        this.optionsString = this.modelValue.join('\n')
      } else {
        this.optionsString = ''
      }
    }
  },
  created () {
    this.optionsString = Array(this.modelValue).flat().join('\n')
  }
}
</script>
