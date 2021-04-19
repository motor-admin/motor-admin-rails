import axios from 'axios'

import qs from 'qs'
import { basePath } from 'utils/scripts/configs'

const api = axios.create({
  baseURL: basePath + 'api',
  paramsSerializer: (params) => {
    return qs.stringify(params, { arrayFormat: 'brackets' })
  }
})

export default api
