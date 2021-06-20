export function scrollToErrors () {
  this.$nextTick(() => {
    const errorField = this.$refs.form.$el.querySelector('.ivu-form-item-error')

    if (errorField) {
      errorField.scrollIntoView()
    } else {
      this.$refs.form.$el.querySelector('.ivu-alert-error')?.scrollIntoView()
    }
  })
}
