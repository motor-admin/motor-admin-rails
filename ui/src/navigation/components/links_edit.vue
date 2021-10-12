<template>
  <VueDraggableNext
    :list="links"
    handle=".handle"
    @change="persistChanges"
  >
    <LinkItem
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
    <LinkForm
      :link="newLink"
      :submit-text="i18n.add_link"
      @cancel="newLink = null"
      @submit="pushNewLink"
    />
  </Card>
  <div
    v-else
    :class="links.length ? 'py-2 border-top' : ''"
  >
    <VButton
      long
      icon="md-add"
      @click="addLink"
    >
      {{ i18n['add_link'] }}
    </VButton>
  </div>
</template>

<script>
import api from 'api'
import LinkItem from './link_item.vue'
import LinkForm from './link_form.vue'
import { linksStore } from '../scripts/links_store'

const defaultLinkParams = {
  name: '',
  path: '',
  link_type: 'header'
}

export default {
  name: 'HeaderEdit',
  components: {
    LinkItem,
    LinkForm
  },
  data () {
    return {
      newLink: null
    }
  },
  computed: {
    links () {
      return linksStore
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

      this.newLink = null
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
