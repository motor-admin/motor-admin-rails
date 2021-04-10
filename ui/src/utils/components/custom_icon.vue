<template>
  <img
    :src="path"
    :style="{ width: size + 'px' }"
  >
</template>

<script>
import { basePath } from 'utils/scripts/configs'

export default {
  name: 'CustomIcon',
  props: {
    type: {
      type: String,
      required: true
    },
    size: {
      type: [Number, String],
      required: false,
      default: '20'
    }
  },
  computed: {
    path () {
      return basePath + 'assets/icons/' + this.type + '.svg'
    }
  }
}
</script>

<style scoped>
img {
  vertical-align: text-bottom;
  filter: invert(34%) sepia(7%) saturate(1441%) hue-rotate(183deg) brightness(97%) contrast(89%);
}

.ivu-menu-item, .ivu-menu-submenu-title {
  img {
    vertical-align: unset;
    margin-bottom: -1px;
  }
}

.ivu-menu-submenu-title:hover, .ivu-menu-item:hover, .ivu-menu-item-active {
  img {
    transition: all 0.2s ease-in-out;
    filter: invert(50%) sepia(95%) saturate(357%) hue-rotate(166deg) brightness(85%) contrast(89%);
  }
}
</style>
