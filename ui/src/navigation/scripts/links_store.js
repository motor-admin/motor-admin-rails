import { reactive } from 'vue'

const linksStore = reactive(JSON.parse(document.getElementById('app').getAttribute('data-header-links')))

export { linksStore }
