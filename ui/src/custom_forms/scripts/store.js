import { reactive } from 'vue'
import api from 'api'

const formsStore = reactive([])

function sortForms (forms) {
  return forms.sort((a, b) => a.updated_at > b.updated_at ? -1 : 1)
}

function assignForms (forms) {
  formsStore.splice(0, formsStore.length, ...sortForms(forms))
}

let requestLock = null

function loadForms () {
  requestLock ||= api.get('forms', {
    params: {
      include: 'tags',
      fields: {
        form: 'id,name,tags,updated_at',
        tags: 'id,name'
      }
    }
  }).then((result) => {
    assignForms(result.data.data)
  }).finally(() => {
    requestLock = null
  })

  return requestLock
}

const appNode = document.getElementById('app')

assignForms(JSON.parse(appNode.getAttribute('data-forms')))

export {
  formsStore,
  loadForms
}
