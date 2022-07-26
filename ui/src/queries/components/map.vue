<template>
  <div
    v-if="data.length && latColumn && lngColumn"
    class="w-100"
  />
  <p
    v-else-if="!loading"
    class="text-center mt-4"
  >
    {{ i18n['no_data'] }}
  </p>
</template>

<script>
import Leaflet from 'leaflet'
import DOMPurify from 'dompurify'
import { basePath } from 'utils/scripts/configs'

const icon = Leaflet.icon({
  iconUrl: basePath + 'assets/images/marker-icon.png',
  iconSize: [25, 41],
  iconAnchor: [10, 40],
  popupAnchor: [3, -36]
})

export default {
  name: 'Map',
  props: {
    data: {
      type: Array,
      required: false,
      default: () => ([])
    },
    columns: {
      type: Array,
      required: false,
      default: () => ([])
    },
    loading: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  computed: {
    latColumn () {
      return this.columns.find((c) => c.title.match(/^lat(?:itude)?$/i)) || this.columns.filter((c) => c.type === 'float')[0]
    },
    lngColumn () {
      return this.columns.find((c) => c.title.toLowerCase() === 'lng' || c.title.match(/^long(?:itude)?$/i)) || this.columns.filter((c) => c.type === 'float')[1]
    },
    valueColumns () {
      return this.columns.filter((c) => c !== this.latColumn && c !== this.lngColumn)
    },
    boundsArray () {
      return this.data.map((row) => {
        return [row[this.latColumn.key], row[this.lngColumn.key]]
      })
    }
  },
  watch: {
    data (oldData, newData) {
      if (JSON.stringify(oldData) !== JSON.stringify(newData)) {
        this.map?.remove()

        this.$nextTick(() => {
          this.renderMap()
        })
      }
    }
  },
  mounted () {
    this.$nextTick(() => {
      this.renderMap()

      this.resizeObserver = new ResizeObserver(() => {
        this.map?.invalidateSize()
      })

      if (this.map?._container) {
        this.resizeObserver.observe(this.map._container)
      }
    })
  },
  unmounted () {
    if (this.map?._container) {
      this.resizeObserver?.unobserve(this.map._container)
    }
  },
  methods: {
    buildPopupHtml (row) {
      return DOMPurify.sanitize(this.valueColumns.map((column) => {
        return `<b>${column.title}</b>: ${row[column.key]}`
      }).join('<br>'))
    },
    renderMap () {
      if (this.data.length) {
        const bounds = new Leaflet.LatLngBounds(this.boundsArray)
        const layer = new Leaflet.TileLayer(
          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          }
        )

        this.map = Leaflet.map(
          this.$el,
          {
            layers: [layer],
            ...(this.data.length === 1 ? { center: this.boundsArray[0], zoom: 10 } : {})
          }
        )

        this.data.forEach((row) => {
          const marker = Leaflet.marker([row[this.latColumn.key], row[this.lngColumn.key]], { icon })
          marker.bindPopup(this.buildPopupHtml(row))

          marker.addTo(this.map)
        })

        if (this.data.length > 1) {
          this.map.fitBounds(bounds, { padding: [50, 50] })
        }
      }
    }
  }
}
</script>

<style>
.leaflet-popup-close-button {
  display: none;
}
</style>
