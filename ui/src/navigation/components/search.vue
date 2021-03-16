<template>
  <AutoComplete
    v-model="value"
    icon="ios-search"
  >
    <VOption
      v-for="(option, index) in options"
      :key="index"
      :value="option.id"
    >
      {{ option }}
    </VOption>
  </AutoComplete>
</template>

<script>
export default {
  name: 'NavigationSearch',
  data () {
    return {
      value: '',
      options: [],
      isLoading: false
    }
  },
  methods: {
    search () {
    }
  }
}
</script>

<style>
</style>
