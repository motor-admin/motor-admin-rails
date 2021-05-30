import { reactive, watch } from 'vue'

const NAVIGATION_HIDE_HELP_KEY = 'motor:navigation:hide_help'
const NAVIGATION_HIDE_WELCOME_KEY = 'motor:navigation:hide_welcome'
const USER_SUBSCRIPTION_KEY = 'motor:current_user:is_subscribed'

const appNode = document.getElementById('app')
const userAttrs = JSON.parse(appNode.getAttribute('data-current-user') || 'null') || {}
const auditsCount = JSON.parse(appNode.getAttribute('data-audits-count'))

const showHelp = auditsCount < 20 && !localStorage.getItem(NAVIGATION_HIDE_HELP_KEY)
const showWelcome = auditsCount === 0 && !localStorage.getItem(NAVIGATION_HIDE_WELCOME_KEY)
const isSubscribed = !!localStorage.getItem(USER_SUBSCRIPTION_KEY)

const currentUser = reactive({
  ...userAttrs,
  auditsCount,
  showWelcome,
  showHelp,
  isSubscribed
})

watch(
  () => currentUser.showHelp,
  (value) => {
    if (value) {
      localStorage.removeItem(NAVIGATION_HIDE_HELP_KEY)
    } else {
      localStorage.setItem(NAVIGATION_HIDE_HELP_KEY, 'true')
    }
  }
)

watch(
  () => currentUser.showWelcome,
  (value) => {
    if (value) {
      localStorage.removeItem(NAVIGATION_HIDE_WELCOME_KEY)
    } else {
      localStorage.setItem(NAVIGATION_HIDE_WELCOME_KEY, 'true')
    }
  }
)

watch(
  () => currentUser.isSubscribed,
  (value) => {
    if (value) {
      localStorage.setItem(USER_SUBSCRIPTION_KEY, 'true')
    } else {
      localStorage.removeItem(USER_SUBSCRIPTION_KEY)
    }
  }
)

export { currentUser }
