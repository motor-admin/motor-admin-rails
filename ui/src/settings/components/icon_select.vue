<template>
  <div style="min-height: 350px">
    <Spin
      v-if="isLoading"
      fix
    />
    <VInput
      v-model="searchQuery"
      search
      :placeholder="i18n['search_placeholder']"
      size="large"
      class="mb-2"
    />
    <div style="min-height: 260px; max-height: 260px; overflowY: auto">
      <span
        v-for="[icon, html] in icons"
        :key="icon"
        @click="$emit('select', icon.replace('.svg', ''))"
        v-html="html"
      />
    </div>
    <VButton
      v-if="!isLoading"
      long
      icon="md-close"
      class="mt-2"
      @click="$emit('close')"
    >
      {{ i18n['close'] }}
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import { reactive } from 'vue'

const icons = reactive([])

export default {
  name: 'IconSelect',
  emits: ['select', 'close'],
  data () {
    return {
      isLoading: false,
      searchQuery: ''
    }
  },
  computed: {
    icons () {
      return icons.filter(([icon, _]) => {
        return icon.includes(this.searchQuery.toLowerCase())
      })
    }
  },
  mounted () {
    this.loadIcons()
  },
  methods: {
    loadIcons () {
      if (!icons.length) {
        this.isLoading = true

        api.get('icons').then((result) => {
          icons.splice(0, 0, ...result.data.data)
        }).catch((error) => {
          console.error(error)
        }).finally(() => {
          this.isLoading = false
        })
      }
    }
  }
}
</script>

<style lang="scss" scoped>
:deep(svg) {
  width: 45px;
  height: 45px;
  padding: 8px 6px;
  cursor: pointer;

  &:hover {
    border-radius: 5px;
    background: #f3f3f3;
  }
}
</style>
