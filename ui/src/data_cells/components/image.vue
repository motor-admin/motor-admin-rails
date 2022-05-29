<template>
  <div
    v-if="photoswipe && value"
    class="photoswipe"
  >
    <a
      ref="container"
      :href="value"
      target="_blank"
      class="cursor-zoom-in"
    >
      <img
        ref="image"
        class="info-image"
        :src="value"
        @load="initPhotoswipe"
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
import PhotoSwipeLightbox from 'photoswipe/lightbox'
import PhotoSwipe from 'photoswipe'

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
  methods: {
    initPhotoswipe (e) {
      this.$refs.container.dataset.pswpWidth = e.target.width * 100
      this.$refs.container.dataset.pswpHeight = e.target.height * 100

      if (this.photoswipe) {
        const options = {
          gallerySelector: '.photoswipe a',
          pswpModule: PhotoSwipe
        }

        const lightbox = new PhotoSwipeLightbox(options)

        lightbox.init()
      }
    },
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
  max-width: 220px;
  vertical-align: top;
}

.pswp img {
  max-width: none;
  object-fit: contain;
}
</style>
