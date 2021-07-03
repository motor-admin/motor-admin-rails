export function copyToClipboard () {
  return navigator.clipboard.writeText(this.value.toString())
}
