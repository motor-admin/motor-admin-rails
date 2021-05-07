<template>
  <VInput
    v-model="optionsString"
    type="textarea"
    placeholder="Options separated with new line or comma"
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
  created () {
    this.optionsString = Array(this.modelValue).flat().join('\n')
  }
}
</script>
