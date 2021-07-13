import { reactive } from 'vue'

const homepageStore = reactive(JSON.parse(document.getElementById('app').getAttribute('data-homepage-layout')))

export { homepageStore }
