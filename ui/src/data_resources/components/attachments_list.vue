<template>
  <div>
    <div
      class="row"
      :style="{ margin: '10px 0' }"
    >
      <div
        v-if="withTitle"
        class="col-6 d-flex align-items-center pe-0"
      >
        <VButton
          v-if="withMenu"
          icon="md-menu"
          size="small"
          type="dashed"
          class="me-2 bg-transparent align-bottom"
          @click="$emit('click-menu')"
        />
        <VButton
          v-if="withResize"
          icon="md-resize"
          size="small"
          type="dashed"
          class="me-2 bg-transparent d-none d-md-block"
          @click="$emit('click-resize')"
        />
        <span
          v-if="withTitle"
          class="fs-4 fw-bold nowrap overflow-hidden text-truncate"
        >{{ title }}
        </span>
      </div>
      <div
        class="col-6 d-flex justify-content-end"
      >
        <VButton
          v-if="isCanUpload"
          class="ms-1"
          icon="md-add"
          type="primary"
          @click="$refs.fileInput.click()"
        >
          {{ i18n.upload }}
        </VButton>
        <input
          v-show="false"
          ref="fileInput"
          type="file"
          multiple
          @change="uploadFiles"
        >
      </div>
    </div>
    <div
      class="position-relative border-top"
    >
      <Spin
        v-if="isLoading"
        fix
      />
      <div
        class="attachments-list d-flex py-2 overflow-auto"
        :style="{ flexWrap: 'wrap', height: height.replace(/\)$/, ' + 33px)'), position: 'relative' }"
        @drop.prevent="uploadFiles"
        @dragover.prevent
      >
        <div
          v-if="!isLoading && !attachments.length"
          class="text-center w-100"
        >
          {{ i18n.there_is_nothing_here_yet }}
        </div>
        <div
          v-for="attachment in attachments"
          :key="attachment.id"
          class="attachment-item-container position-relative"
        >
          <a
            v-if="isImage(attachment.path)"
            :href="attachment.path"
            target="_blank"
            class="d-block image-container mx-2 py-2 cursor-zoom-in photoswipe"
          >

            <VButton
              v-if="isCanRemove"
              type="error"
              icon="md-trash"
              class="remove-btn rounded-0"
              size="small"
              @click="remove($event, attachment)"
            />
            <img
              :src="attachment.path"
              style="width: 100%"
              @load="setPswpData"
            >
          </a>
          <div
            v-else-if="isAudio(attachment.path)"
            class="mx-2 py-2 d-block text-center"
          >
            <audio
              controls
              preload="metadata"
              class="align-middle w-100"
              :src="attachment.path"
            />
            <div class="mt-1 audio-filename">
              <span class="text-break-all">
                {{ attachment.path.split('/').pop() }}
              </span>
              <VButton
                v-if="isCanRemove"
                type="text"
                icon="md-trash"
                class="bg-transparent"
                @click="remove($event, attachment)"
              />
            </div>
          </div>
          <div
            v-else-if="isVideo(attachment.path)"
            class="mx-2 video-container py-2 d-block text-center"
          >
            <VButton
              v-if="isCanRemove"
              type="error"
              icon="md-trash"
              class="remove-btn rounded-0"
              size="small"
              @click="remove($event, attachment)"
            />
            <video
              controls
              class="align-middle w-100"
              :src="attachment.path"
            />
          </div>
          <a
            v-else
            :href="attachment.path"
            class="mx-2 py-2 d-block"
            target="_blank"
          >
            <div
              style="min-height: 200px"
              class="file-container d-flex bg-white rounded justify-content-center align-items-center border flex-column"
            >
              <Icon
                type="md-download"
                size="large"
                class="fs-1"
              />
              <span class="text-break-all text-center">
                {{ attachment.path.split('/').pop() }}
              </span>
              <VButton
                v-if="isCanRemove"
                type="error"
                icon="md-trash"
                class="remove-btn rounded-0"
                size="small"
                @click="remove($event, attachment)"
              />
            </div>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from 'api'
import { modelNameMap } from '../scripts/schema'
import { truncate } from 'utils/scripts/string'

import PhotoSwipeLightbox from 'photoswipe/lightbox'
import PhotoSwipe from 'photoswipe'

export default {
  name: 'AttachmentsList',
  props: {
    resourceName: {
      type: String,
      required: true
    },
    height: {
      type: String,
      required: false,
      default: '500px'
    },
    withTitle: {
      type: Boolean,
      required: false,
      default: false
    },
    withResize: {
      type: Boolean,
      required: false,
      default: false
    },
    withMenu: {
      type: Boolean,
      required: false,
      default: false
    },
    associationParams: {
      type: Object,
      require: false,
      default: null
    }
  },
  emits: ['click-resize', 'click-menu'],
  data () {
    return {
      isLoading: true,
      isDownloadLoading: false,
      attachments: []
    }
  },
  computed: {
    isCanRemove () {
      return this.$can('edit', this.model.class_name, this.associationParams) && this.$can('remove', 'ActiveStorage::Attachment')
    },
    isCanUpload () {
      return this.$can('edit', this.model.class_name, this.associationParams) && this.$can('create', 'ActiveStorage::Attachment')
    },
    title () {
      return truncate(this.association.display_name, 60)
    },
    queryPath () {
      return [
        'data',
        this.model.slug,
        this.associationParams.id,
        this.associationParams.name
      ].join('/')
    },
    model () {
      return modelNameMap[this.resourceName]
    },
    association () {
      if (this.associationParams?.name) {
        return this.model.associations.find((assoc) => {
          return assoc.slug === this.associationParams.name
        })
      } else {
        return null
      }
    }
  },
  mounted () {
    this.loadData().then(() => {
      const options = {
        gallerySelector: '.attachments-list',
        childSelector: 'a.photoswipe',
        pswpModule: PhotoSwipe
      }

      const lightbox = new PhotoSwipeLightbox(options)

      lightbox.init()
    })
  },
  methods: {
    isImage (path) {
      return !!path.match(/\.(jpg|png|jpeg|webp|svg|gif)$/i)
    },
    isVideo (path) {
      return !!path.match(/\.(mp4|mov|flv|webm)$/i)
    },
    isAudio (path) {
      return !!path.match(/\.(mp3|ogg|wav|aif)$/i)
    },
    remove (event, attachment) {
      event.stopPropagation()
      event.preventDefault()

      this.$Dialog.confirm({
        title: this.i18n.are_you_sure,
        closable: true,
        onOk: () => {
          this.isLoading = true

          api.delete(`data/active_storage__attachments/${attachment.id}`, {
          }).catch((error) => {
            console.error(error)
          }).finally((result) => {
            this.loadData()
          })
        }
      })
    },
    uploadFiles (event) {
      this.isLoading = true

      return Promise.all([...(event.dataTransfer?.files || event.target.files)].map((file) => {
        return new Promise((resolve, reject) => {
          const reader = new FileReader()

          reader.readAsBinaryString(file)

          reader.onerror = reject
          reader.onload = () => {
            resolve(reader.result)
          }
        }).then((data) => {
          return api.post('data/active_storage__attachments', {
            name: this.associationParams.name.replace(/_attachments?$/, ''),
            record_id: this.associationParams.id,
            record_type: this.model.class_name,
            file: {
              filename: file.name,
              io: data
            }
          })
        })
      })).finally(() => {
        this.loadData()
      })
    },
    setPswpData (e) {
      const containerEl = e.target.parentElement

      containerEl.dataset.pswpWidth = e.target.width * 100
      containerEl.dataset.pswpHeight = e.target.height * 100
    },
    loadData () {
      this.isLoading = true

      return api.get(this.queryPath, {
        params: {
          limit: 1000,
          fields: {
            attachment: 'id,path,created_at,updated_at,name'
          }
        }
      }).then((result) => {
        this.attachments = result.data.data
      }).catch((error) => {
        if (error.response) {
          this.$Message.error(truncate(error.response.data.errors.join('\n'), 70))
        } else {
          this.$Message.error(error.message)
        }
      }).finally(() => {
        this.$nextTick(() => {
          this.isLoading = false
        })
      })
    }
  }
}
</script>

<style lang="scss" scoped>
@import 'utils/styles/variables';

.attachment-item-container {
  width: 50%
}

@media screen and (min-width: $breakpoint-md) {
  .attachment-item-container {
    width: 33%
  }
}

@media screen and (min-width: $breakpoint-lg) {
  .attachment-item-container {
    width: 25%
  }
}

.remove-btn {
  display: none;
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 999;
}

.file-container:hover, .image-container:hover, .video-container:hover {
  .remove-btn {
    display: block
  }
}
</style>
