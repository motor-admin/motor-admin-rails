<template>
  <div
    v-if="photoswipe && value"
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
        class="info-image"
        :src="value"
      >
    </a>
  </div>
  <img
    v-else-if="value"
    class="table-image"
    :src="value"
  >
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
  },
  methods: {
    copyToClipboard () {
      const url = this.value[0] === '/' ? document.location.origin + this.value : this.value

      return navigator.clipboard.writeText(url)
    }
  }
}
</script>

<style lang="scss">
.table-image {
  height: 80px;
  width: 80px;
  border-radius: 4px;
  object-fit: cover;
  margin: 2px 0;
  vertical-align: top;
}

.info-image {
  max-height: 120px;
  vertical-align: top;
}

.pswp img {
  max-width: none;
  object-fit: contain;
}
</style>
