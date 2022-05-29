<template>
  <MSelect
    :model-value="modelValue"
    filterable
    :size="size"
    :placeholder="i18n['timezone']"
    :options="options"
    :with-deselect="false"
    @update:model-value="updateValue"
  />
</template>

<script>
export default {
  name: 'TimezoneSelect',
  props: {
    modelValue: {
      type: String,
      required: false,
      default () {
        return localStorage.getItem('timezone') || ''
      }
    },
    size: {
      type: String,
      required: false,
      default: 'default'
    }
  },
  emits: ['update:modelValue'],
  computed: {
    options () {
      return [
        'UTC',
        'Eastern Time (US & Canada)',
        'Central Time (US & Canada)',
        'Mountain Time (US & Canada)',
        'Pacific Time (US & Canada)',
        'Atlantic Time (Canada)',
        'Abu Dhabi',
        'Adelaide',
        'Alaska',
        'Almaty',
        'American Samoa',
        'Amsterdam',
        'Arizona',
        'Astana',
        'Athens',
        'Auckland',
        'Azores',
        'Baghdad',
        'Baku',
        'Bangkok',
        'Beijing',
        'Belgrade',
        'Berlin',
        'Bern',
        'Bogota',
        'Brasilia',
        'Bratislava',
        'Brisbane',
        'Brussels',
        'Bucharest',
        'Budapest',
        'Buenos Aires',
        'Cairo',
        'Canberra',
        'Cape Verde Is.',
        'Caracas',
        'Casablanca',
        'Central America',
        'Chatham Is.',
        'Chennai',
        'Chihuahua',
        'Chongqing',
        'Copenhagen',
        'Darwin',
        'Dhaka',
        'Dublin',
        'Edinburgh',
        'Ekaterinburg',
        'Fiji',
        'Georgetown',
        'Greenland',
        'Guadalajara',
        'Guam',
        'Hanoi',
        'Harare',
        'Hawaii',
        'Helsinki',
        'Hobart',
        'Hong Kong',
        'Indiana (East)',
        'International Date Line West',
        'Irkutsk',
        'Islamabad',
        'Istanbul',
        'Jakarta',
        'Jerusalem',
        'Kabul',
        'Kaliningrad',
        'Kamchatka',
        'Karachi',
        'Kathmandu',
        'Kolkata',
        'Krasnoyarsk',
        'Kuala Lumpur',
        'Kuwait',
        'Kyiv',
        'La Paz',
        'Lima',
        'Lisbon',
        'Ljubljana',
        'London',
        'Madrid',
        'Magadan',
        'Marshall Is.',
        'Mazatlan',
        'Melbourne',
        'Mexico City',
        'Mid-Atlantic',
        'Midway Island',
        'Minsk',
        'Monrovia',
        'Monterrey',
        'Montevideo',
        'Moscow',
        'Mumbai',
        'Muscat',
        'Nairobi',
        'New Caledonia',
        'New Delhi',
        'Newfoundland',
        'Novosibirsk',
        "Nuku'alofa",
        'Osaka',
        'Paris',
        'Perth',
        'Port Moresby',
        'Prague',
        'Pretoria',
        'Puerto Rico',
        'Quito',
        'Rangoon',
        'Riga',
        'Riyadh',
        'Rome',
        'Samara',
        'Samoa',
        'Santiago',
        'Sapporo',
        'Sarajevo',
        'Saskatchewan',
        'Seoul',
        'Singapore',
        'Skopje',
        'Sofia',
        'Solomon Is.',
        'Srednekolymsk',
        'Sri Jayawardenepura',
        'St. Petersburg',
        'Stockholm',
        'Sydney',
        'Taipei',
        'Tallinn',
        'Tashkent',
        'Tbilisi',
        'Tehran',
        'Tijuana',
        'Tokelau Is.',
        'Tokyo',
        'Ulaanbaatar',
        'Urumqi',
        'Vienna',
        'Vilnius',
        'Vladivostok',
        'Volgograd',
        'Warsaw',
        'Wellington',
        'West Central Africa',
        'Yakutsk',
        'Yerevan',
        'Zagreb',
        'Zurich'
      ]
    }
  },
  mounted () {
    this.$emit('update:modelValue', this.modelValue)
  },
  methods: {
    updateValue (value) {
      localStorage.setItem('timezone', value)

      this.$emit('update:modelValue', value)
    }
  }
}
</script>
