<template>
  <VueDraggableNext
    :list="links"
    @change="persistChanges"
  >
    <HeaderLink
      v-for="link in links"
      :key="link.path"
      :link="link"
      class="pb-2"
      @remove="removeLink"
      @submit="replaceLink"
    />
  </VueDraggableNext>
  <Card
    v-if="newLink"
  >
    <HeaderLinkForm
      :link="newLink"
      @cancel="newLink = null"
      @submit="pushNewLink"
    />
  </Card>
  <div
    v-else
    class="py-2 border-top"
  >
    <VButton
      long
      icon="md-add"
      @click="addLink"
    >
      Add Link
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import HeaderLink from './header_link_item.vue'
import HeaderLinkForm from './header_link_form.vue'

const defaultLinkParams = {
  name: '',
  path: ''
}

export default {
  name: 'HeaderEdit',
  components: {
    HeaderLink,
    HeaderLinkForm
  },
  props: {
    links: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      newLink: null
    }
  },
  mounted () {
    if (!this.links.length) {
      this.addLink()
    }
  },
  methods: {
    addLink () {
      this.newLink = { ...defaultLinkParams }
    },
    removeLink (link) {
      const index = this.links.indexOf(link)

      this.links.splice(index, 1)

      this.persistChanges()
    },
    onSubmitNew (link) {
      this.newLink = null

      this.onLinkSubmit(link)
    },
    replaceLink ([oldLink, newLink]) {
      const index = this.links.indexOf(oldLink)

      this.links.splice(index, 1, newLink)

      this.persistChanges()
    },
    pushNewLink ([oldLink, newLink]) {
      this.links.push(newLink)

      this.persistChanges()
    },
    persistChanges () {
      return api.post('configs', {
        data: {
          key: 'header.links',
          value: this.links
        }
      }).then((result) => {
      }).catch((error) => {
        console.error(error)
      })
    }
  }
}
</script>
