import { reactive } from 'vue'
import api from 'api'

const formsCache = reactive({})

let requestLock = null

function addForm (form) {
  if (formsCache[form.id]) {
    Object.assign(formsCache[form.id], form)
  } else {
    formsCache[form.id] = form
  }
}

async function loadFormFromCache (id) {
  if (!formsCache[id]) {
    await loadFormsToCache([id])
  } else {
    loadFormsToCache([id])
  }

  return formsCache[id]
}

function loadFormsToCache (ids) {
  requestLock ||= api.get('forms', {
    params: {
      include: 'tags',
      filter: {
        id: Array.isArray(ids) ? ids : [ids]
      },
      fields: {
        form: 'id,name,api_path,http_method,preferences,api_config_name,tags,updated_at'
      }
    }
  }).then((result) => {
    result.data.data.forEach((form) => addForm(form))
  }).finally(() => {
    requestLock = null
  })

  return requestLock
}

export {
  formsCache,
  loadFormsToCache,
  loadFormFromCache
}
