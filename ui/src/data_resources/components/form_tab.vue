<template>
  <div
    class="p-3"
  >
    <Card
      style="max-width: 600px; margin: 0 auto"
    >
      <CustomFormModal
        :form-id="tab.preferences.form_id"
        :data="data"
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
  }
}
</script>
