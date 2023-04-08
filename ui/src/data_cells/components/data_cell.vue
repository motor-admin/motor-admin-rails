<template>
  <DateTime
    v-if="isDateTime"
    ref="cell"
    :value="stringValue"
    :display-time="type !== 'date'"
    :is-date="type === 'date'"
  />
  <DataRichtext
    v-else-if="isRichtext"
    ref="cell"
    :truncate="textTruncate"
    :value="value"
  />
  <DataPercentage
    v-else-if="isPercentage"
    ref="cell"
    :value="value"
  />
  <DataColor
    v-else-if="isColor"
    ref="cell"
    :value="value"
  />
  <DataChange
    v-else-if="isChange"
    ref="cell"
    :value="value"
  />
  <DataChart
    v-else-if="isChart"
    ref="cell"
    :value="value"
  />
  <DataCurrency
    v-else-if="isCurrency"
    ref="cell"
    :value="value"
    :format="format"
  />
  <DataTag
    v-else-if="isTag"
    ref="cell"
    :value="value"
    :format="format"
    :with-filter-button="isTable"
    @tag-click="$emit('tag-click', $event)"
  />
  <DataImage
    v-else-if="isImage"
    ref="cell"
    :photoswipe="!textTruncate"
    :value="stringValue"
  />
  <DataAudio
    v-else-if="isAudio"
    ref="cell"
    :value="stringValue"
  />
  <DataVideo
    v-else-if="isVideo"
    ref="cell"
    :is-table="textTruncate"
    :value="stringValue"
  />
  <DataLink
    v-else-if="isUrl || isPath"
    ref="cell"
    :truncate="textTruncate"
    :format="format"
    :value="stringValue"
  />
  <DataBoolean
    v-else-if="isBoolean"
    ref="cell"
    :value="value"
  />
  <DataEmail
    v-else-if="isEmail"
    ref="cell"
    :truncate="textTruncate"
    :value="value"
  />
  <DataPhone
    v-else-if="isPhone"
    ref="cell"
    :truncate="textTruncate"
    :value="value"
  />
  <DataNumber
    v-else-if="isNumber"
    ref="cell"
    :value="value"
    :with-format="format.number_format"
  />
  <DataRating
    v-else-if="type === 'rating'"
    ref="cell"
    :value="value"
  />
  <DataText
    v-else
    ref="cell"
    :truncate="textTruncate"
    :value="stringValue"
  />
</template>

<script>
import DateTime from './date_time'
import DataText from './text'
import DataLink from './link'
import DataTag from './tag'
import DataImage from './image'
import DataBoolean from './boolean'
import DataEmail from './email'
import DataPhone from './phone'
import DataCurrency from './currency'
import DataRichtext from './richtext'
import DataPercentage from './percentage'
import DataChange from './change'
import DataChart from './chart'
import DataColor from './color'
import DataAudio from './audio'
import DataVideo from './video'
import DataNumber from './number'
import DataRating from './rating'

import DataTypes from '../scripts/data_types'

export default {
  name: 'DataCell',
  components: {
    DataText,
    DateTime,
    DataLink,
    DataTag,
    DataImage,
    DataBoolean,
    DataEmail,
    DataPhone,
    DataCurrency,
    DataRichtext,
    DataPercentage,
    DataChange,
    DataChart,
    DataColor,
    DataAudio,
    DataVideo,
    DataNumber,
    DataRating
  },
  props: {
    value: {
      type: [String, Number, Object, Boolean],
      required: false,
      default: ''
    },
    type: {
      type: String,
      required: false,
      default: DataTypes.TEXT
    },
    format: {
      type: Object,
      required: false,
      default: () => ({})
    },
    isTable: {
      type: Boolean,
      required: false,
      default: false
    },
    textTruncate: {
      type: Boolean,
      required: false,
      default: true
    }
  },
  emits: ['tag-click'],
  computed: {
    stringValue () {
      if (this.value && typeof this.value === 'object') {
        return JSON.stringify(this.value, null, '  ')
      } else if (typeof this.value === 'number') {
        return this.value.toString()
      } else {
        return (this.value ?? '').toString()
      }
    },
    isDateTime () {
      return this.type === DataTypes.DATE_TIME || this.type === DataTypes.DATE
    },
    isTag () {
      return this.type === DataTypes.TAG
    },
    isPhone () {
      return !!this.stringValue.match(/^\+[\d\s()-]{5,}$/)
    },
    isEmail () {
      return !!this.stringValue.match(/^[\w.]+@[\w-]+\.\w{2,3}/)
    },
    isBoolean () {
      return this.type === 'boolean'
    },
    isPercentage () {
      return this.type === 'percentage'
    },
    isChange () {
      return this.type === 'change'
    },
    isNumber () {
      return this.type === 'integer' || this.type === 'float' || this.type === 'number'
    },
    isChart () {
      return this.type === 'chart'
    },
    isImage () {
      return this.type === 'image' || (this.isPath && !!this.stringValue.match(/\.(jpg|png|jpeg|webp|svg|gif)$/i))
    },
    isAudio () {
      return this.type === 'audio' || (this.isPath && !!this.stringValue.match(/\.(mp3|ogg|wav|aif)$/i))
    },
    isVideo () {
      return this.type === 'video' || (this.isPath && !!this.stringValue.match(/\.(mp4|mov|flv|webm)$/i))
    },
    isCurrency () {
      return this.type === 'currency'
    },
    isColor () {
      return this.type === 'color'
    },
    isRichtext () {
      return this.type === 'richtext'
    },
    isUrl () {
      return this.type === 'link' || !!this.stringValue.match(/^https?:\/\//i)
    },
    isPath () {
      return !!this.stringValue.match(/^\/[^\s]+$/i)
    }
  }
}
</script>
