<template>
  <div class="d-flex align-items-center controls">
    <div class="d-flex flex-column align-items-center">
      <i
        class="ion ion-md-arrow-dropup"
        @click.prevent="toggle('width', -1)"
      />
      <VButton
        class="width"
        type="dashed"
        @click="toggle('width', 1)"
      >
        {{ dataValue[0] }}
      </VButton>
      <i
        class="ion ion-md-arrow-dropdown"
        @click.prevent="toggle('width', 1)"
      />
    </div>
    <span class="divider">
      x
    </span>
    <div class="d-flex flex-column align-items-center">
      <i
        class="ion ion-md-arrow-dropup"
        @click.prevent="toggle('height', -1)"
      />
      <VButton
        class="height"
        type="dashed"
        @click="toggle('height', 1)"
      >
        {{ dataValue[1] }}
      </VButton>
      <i
        class="ion ion-md-arrow-dropdown"
        @click.prevent="toggle('height', 1)"
      />
    </div>
  </div>
</template>

<script>
export default {
  name: 'DashboardSizeControl',
  props: {
    modelValue: {
      type: String,
      required: false,
      default: () => '3x2'
    },
    maxValues: {
      type: Array,
      required: false,
      default: () => [6, 4]
    }
  },
  emits: ['update:modelValue'],
  data () {
    return {
      dataValue: this.modelValue.split('x').map((e) => parseInt(e))
    }
  },
  watch: {
    modelValue (value) {
      this.dataValue = value.split('x').map((e) => parseInt(e))
    }
  },
  methods: {
    toggle (key, change) {
      const index = key === 'width' ? 0 : 1

      let nextValue = this.dataValue[index] + change

      if (nextValue > this.maxValues[index]) {
        nextValue = 1
      } else if (nextValue < 1) {
        nextValue = this.maxValues[index]
      }

      this.dataValue[index] = nextValue

      this.$emit('update:modelValue', this.dataValue.join('x'))
    }
  }
}
</script>

<style lang="scss" scoped>
div {
  font-family: Monospace;
}

.ion {
  cursor: pointer;
  color: white;
}

.controls:hover {
  .ion {
    color: unset;
  }
}

.ivu-btn {
  height: 24px;
  padding: 0 7px;
}

.divider {
  text-align: center;
  width: 20px
}
</style>
