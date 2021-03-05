import Vuex from 'vuex'

import { schema } from 'utils/scripts/configs'

const store = new Vuex.Store({
  state: {
    schema
  },
  actions: {
  },
  mutations: {
  },
  getters: {
    schema: state => state.schema,
    slugsMap: state => Object.fromEntries(state.schema.map((res) => [res.slug, res]))
  }
})

export default store
