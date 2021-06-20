<template>
  <div>
    <VForm
      ref="form"
      :rules="rules"
      label-position="top"
      :model="dataGroup"
      @submit.prevent="submit"
    >
      <FormItem
        label="Name"
        prop="display_name"
        :class="dataGroup.display_name && !isCustomName ? 'mb-0' : ''"
      >
        <VInput
          ref="nameInput"
          v-model="dataGroup.display_name"
          placeholder="Group name"
          @drag.stop
        />
      </FormItem>
      <p
        v-if="!isCustomName && generatedParamName"
        style="margin-bottom: 6px; font-size: 12px"
      >
        Param name: <code>{{ generatedParamName }}</code>
        <Icon
          type="md-create"
          class="ms-1 cursor-pointer"
          @click="toggleCustomParam"
        />
      </p>
      <FormItem
        v-if="isCustomName"
        label="Param name"
        prop="name"
      >
        <VInput
          v-model="dataGroup.name"
          placeholder="Request param"
          @drag.stop
        />
      </FormItem>
      <Checkbox
        v-model="dataGroup.is_array"
        class="d-block mb-3"
      >
        Multiple
      </Checkbox>
    </VForm>
    <div class="d-flex justify-content-between">
      <div>
        <VButton
          v-if="withRemove"
          type="error"
          ghost
          class="me-2"
          @click="$emit('remove')"
        >
          Remove
        </VButton>
        <VButton
          @click="$emit('cancel')"
        >
          Cancel
        </VButton>
      </div>
      <VButton
        type="primary"
        @click="submit"
      >
        {{ okText }}
      </VButton>
    </div>
  </div>
</template>

<script>
import { underscore } from 'utils/scripts/string'

export default {
  name: 'GroupForm',
  components: {
  },
  props: {
    group: {
      type: Object,
      required: true
    },
    okText: {
      type: String,
      required: false,
      default: 'OK'
    },
    focus: {
      type: Boolean,
      required: false,
      default: false
    },
    withRemove: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  emits: ['submit', 'remove', 'cancel'],
  data () {
    return {
      dataGroup: {},
      isCustomName: false
    }
  },
  computed: {
    rules () {
      return {
        display_name: [{ required: true }],
        name: [{ required: true }]
      }
    },
    generatedParamName () {
      const name = underscore(this.dataGroup.display_name)

      return name
    }
  },
  mounted () {
    if (this.focus) {
      this.$refs.nameInput.$el.querySelector('input').focus()
    }
  },
  created () {
    this.dataGroup = JSON.parse(JSON.stringify(this.group))

    if (this.dataGroup.display_name) {
      this.isCustomName = this.generatedParamName !== this.dataGroup.name
    }
  },
  methods: {
    submit () {
      this.$refs.form.validate((valid) => {
        if (valid) {
          if (!this.isCustomName) {
            this.dataGroup.name = this.generatedParamName
          }

          this.$emit('submit', this.dataGroup)
        }
      })
    },
    toggleCustomParam () {
      this.isCustomName = true

      this.dataGroup.name = this.generatedParamName
    }
  }
}
</script>

<style lang="scss" scoped>
.cursor-pointer {
  display: none
}

p:hover {
  .cursor-pointer {
    display: inline
  }
}
</style>
