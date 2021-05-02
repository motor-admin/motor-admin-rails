import { ref } from 'vue'
import throttle from 'view3/src/utils/throttle'

const breakpoints = {
  xs: 0,
  sm: 576,
  md: 768,
  lg: 992,
  xl: 1200,
  xxl: 1400
}

const windowWidth = ref(window.innerWidth)
const windowHeight = ref(window.innerHeight)

function widthLessThan (breakpoint) {
  return windowWidth.value < breakpoints[breakpoint]
}

window.addEventListener('resize', throttle((event) => {
  windowWidth.value = window.innerWidth
  windowHeight.value = window.innerHeight
}, 80))

export { windowWidth, windowHeight, widthLessThan }
