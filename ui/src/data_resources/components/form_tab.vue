<template>
  <div
    class="p-3"
  >
    <Spin
      v-if="isLoading"
      fix
    />
    <Card
      v-show="!isLoading"
      style="max-width: 600px; margin: 0 auto"
    >
      <CustomFormModal
        :form-id="tab.preferences.form_id"
        :data="data"
        @loaded="isLoading = false"
      />
    </Card>
  </div>
</template>

<script>
import CustomFormModal from 'custom_forms/components/form_modal'

export default {
  name: 'ResourceFormTab',
  components: {
    CustomFormModal
  },
  props: {
    data: {
      type: Object,
      required: false,
      default: () => ({})
    },
    tab: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      isLoading: true
    }
  }
}
</script>
