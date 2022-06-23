<template>
  <VInput
    v-model="optionsString"
    type="textarea"
    :placeholder="i18n['options_separated_with_new_line_or_comma']"
    :autosize="{ minRows: 3, maxRows: 7 }"
    @update:model-value="$emit('update:modelValue', optionsArray)"
  />
</template>

<script>
export default {
  name: 'OptionsSelect',
  props: {
    modelValue: {
      type: [Array, String, Object],
      required: false,
      default: () => []
    },
    optionsText: {
      type: [String],
      required: false,
      default: ''
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

        const options = this.optionsString.split(delimiter).map((e) => e.trim())
          .filter((el, i, a) => i === a.indexOf(el))
          .filter(e => !e.match(/^\s*$/))

        const isMap = options.every((o) => o.match(/[;,]/))

        if (isMap) {
          return options.reduce((acc, o) => {
            const [key, value] = o.split(/[;,]/)

            acc[key.trim()] = value.trim()

            return acc
          }, {})
        } else {
          return options
        }
      } else {
        return []
      }
    }
  },
  watch: {
    modelValue () {
      if (!this.modelValue) {
        this.optionsString = ''
      }
    },
    optionsText () {
      this.optionsString = this.optionsText
    }
  },
  created () {
    this.assignOptionsString()
  },
  methods: {
    assignOptionsString () {
      if (this.modelValue.length) {
        this.optionsString = Array(this.modelValue).flat().join('\n')
      } else {
        this.optionsString = Object.entries(this.modelValue).map((e) => e.join(',')).join('\n')
      }
    }
  }
}
</script>
