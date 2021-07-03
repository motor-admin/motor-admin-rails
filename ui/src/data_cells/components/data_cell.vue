<template>
  <DateTime
    v-if="isDateTime"
    ref="cell"
    :value="stringValue"
    :display-time="type !== 'date'"
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
  />
  <DataImage
    v-else-if="isImage"
    ref="cell"
    :photoswipe="!textTruncate"
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
    DataColor
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
    textTruncate: {
      type: Boolean,
      required: false,
      default: true
    }
  },
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
    isChart () {
      return this.type === 'chart'
    },
    isImage () {
      return this.type === 'image' || (this.isPath && !!this.stringValue.match(/\.(jpg|png|jpeg|wepb|svg)$/i))
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
      return !!this.stringValue.match(/^https?:\/\//i)
    },
    isPath () {
      return !!this.stringValue.match(/^\/[^\s]+$/i)
    }
  }
}
</script>
