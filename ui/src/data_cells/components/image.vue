<template>
  <div
    v-if="photoswipe"
    class="photoswipe"
  >
    <a
      :href="value"
      target="_blank"
      class="cursor-zoom-in"
      data-pswp-width="3000"
      data-pswp-height="3000"
    >
      <img
        class="table-image"
        :src="value"
      >
    </a>
  </div>
  <div
    v-else
    class="text-center"
  >
    <img
      class="table-image"
      :src="value"
    >
  </div>
</template>

<script>
import PhotoSwipeLightbox from 'photoswipe/dist/photoswipe-lightbox.esm.js'
import PhotoSwipe from 'photoswipe/dist/photoswipe.esm.js'

import 'photoswipe/dist/photoswipe.css'

export default {
  name: 'DataImage',
  props: {
    value: {
      type: String,
      required: true
    },
    photoswipe: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  mounted () {
    if (this.photoswipe) {
      const options = {
        gallerySelector: '.photoswipe a',
        pswpModule: PhotoSwipe
      }

      const lightbox = new PhotoSwipeLightbox(options)

      lightbox.init()
    }
  }
}
</script>

<style lang="scss">
.table-image {
  max-height: 120px;
  vertical-align: top;
}
.pswp img {
  max-width: none;
  object-fit: contain;
}
</style>
