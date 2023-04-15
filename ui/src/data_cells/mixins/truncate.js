const MAX_LENGTH = 60 // chars

export default {
  props: {
    truncate: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  computed: {
    isTruncated () {
      if (this.truncate) {
        return this.value.length > MAX_LENGTH
      } else {
        return false
      }
    },
    truncatedValue () {
      if (this.isTruncated) {
        let value = this.value.slice(0, MAX_LENGTH)

        if (!this.truncateWithoutDots) {
          value = value.concat('...')
        }

        return value
      } else {
        return this.value
      }
    }
  }
}
