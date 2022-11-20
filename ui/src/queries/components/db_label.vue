<template>
  <span>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="align-middle"
      width="14"
      height="14"
      viewBox="0 0 24 24"
      stroke-width="1.5"
      stroke="#2c3e50"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path
        stroke="none"
        d="M0 0h24v24H0z"
        fill="none"
      />
      <ellipse
        cx="12"
        cy="6"
        rx="8"
        ry="3"
      />
      <path d="M4 6v6a8 3 0 0 0 16 0v-6" />
      <path d="M4 12v6a8 3 0 0 0 16 0v-6" />
    </svg>
    <span class="align-middle ms-1">
      {{ option.label }}
    </span>
  </span>
</template>

<script>
export default {
  name: 'DbLabel',
  props: {
    option: {
      type: Object,
      required: true
    }
  }
}
</script>
