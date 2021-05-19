import { ref } from 'vue'

const isShowSettingsRef = ref(false)

function toggleSettings () {
  isShowSettingsRef.value = !isShowSettingsRef.value
}

function closeSettings () {
  isShowSettingsRef.value = false
}

function isShowSettings () {
  return isShowSettingsRef.value
}

export { isShowSettings, toggleSettings, closeSettings }
