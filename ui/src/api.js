import axios from 'axios'

import qs from 'qs'
import { deserialise } from 'kitsu-core'
import { basePath } from 'utils/scripts/configs'

const api = axios.create({
  baseURL: basePath,
  paramsSerializer: (params) => {
    return qs.stringify(params, { arrayFormat: 'brackets' })
  }
})

api.interceptors.response.use(async (response) => {
  if (response.data?.data) {
    response.data = await deserialise(response.data)
  }

  return response
}, (error) => {
  return Promise.reject(error)
})

export default api
