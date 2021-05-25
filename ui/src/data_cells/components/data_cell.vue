<template>
  <DateTime
    v-if="isDateTime"
    :value="stringValue"
  />
  <DataImage
    v-else-if="isImage"
    :value="stringValue"
  />
  <DataCurrency
    v-else-if="isCurrency"
    :value="value"
    :format="format"
  />
  <DataUrl
    v-else-if="isUrl || isPath"
    :truncate="textTruncate"
    :value="stringValue"
  />
  <DataBoolean
    v-else-if="isBoolean"
    :value="value"
  />
  <DataTag
    v-else-if="isTag && stringValue"
    :value="stringValue"
  />
  <DataEmail
    v-else-if="isEmail"
    :truncate="textTruncate"
    :value="value"
  />
  <DataPhone
    v-else-if="isPhone"
    :truncate="textTruncate"
    :value="value"
  />
  <DataText
    v-else
    :truncate="textTruncate"
    :value="stringValue"
  />
</template>

<script>
import DateTime from './date_time'
import DataText from './text'
import DataUrl from './url'
import DataTag from './tag'
import DataImage from './image'
import DataBoolean from './boolean'
import DataEmail from './email'
import DataPhone from './phone'
import DataCurrency from './currency'

import DataTypes from '../scripts/data_types'

export default {
  name: 'DataCell',
  components: {
    DataText,
    DateTime,
    DataUrl,
    DataTag,
    DataImage,
    DataBoolean,
    DataEmail,
    DataPhone,
    DataCurrency
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
      return this.type === DataTypes.DATE_TIME || this.type === DataTypes.TIMESTAMP
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
    isImage () {
      return (this.isPath && !!this.stringValue.match(/\.(jpg|png|jpeg|wepb|svg)$/i)) || this.type === 'image'
    },
    isCurrency () {
      return this.type === 'currency'
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

<style lang="scss">

</style>
