import './index.scss'

import { createApp } from 'vue'

import App from './app'

import router from './router'
import store from './store'

import PopoverDirective from 'view3/src/directives/popover'
import VueClipboard from 'view3/src/directives/clipboard'

import DynamicModal from 'view3/src/plugins/dynamic-modal'
import DynamicDrawer from 'view3/src/plugins/dynamic-drawer'
import DynamicPopover from 'view3/src/plugins/dynamic-popover'

import Button from 'view3/src/components/button'
import Submenu from 'view3/src/components/submenu'
import Menu from 'view3/src/components/menu'
import MenuItem from 'view3/src/components/menu-item'
import Header from 'view3/src/components/header'
import Switch from 'view3/src/components/switch'
import Card from 'view3/src/components/card'
import Icon from 'view3/src/components/icon'
import Input from 'view3/src/components/input'
import Form from 'view3/src/components/form'
import FormItem from 'view3/src/components/form-item'
import Radio from 'view3/src/components/radio'
import RadioGroup from 'view3/src/components/radio-group'
import Spin from 'view3/src/components/spin'
import Checkbox from 'view3/src/components/checkbox'
import Affix from 'view3/src/components/affix'
import Tag from 'view3/src/components/tag'
import Divider from 'view3/src/components/divider'
import Collapse from 'view3/src/components/collapse'
import Panel from 'view3/src/components/panel'
import Tooltip from 'view3/src/components/tooltip'
import Select from 'view3/src/components/select'
import Option from 'view3/src/components/option'
import Cell from 'view3/src/components/cell'
import CellGroup from 'view3/src/components/cell-group'

import ContentPlaceholders from 'vue-content-placeholders/src/components/ContentPlaceholders'
import ContentPlaceholdersText from 'vue-content-placeholders/src/components/ContentPlaceholdersText'

const app = createApp(App)

app.directive('popover', PopoverDirective)
app.directive('clipboard', VueClipboard)

app.component('IButton', Button)
app.component('ISwitch', Switch)
app.component('Menu', Menu)
app.component('Submenu', Submenu)
app.component('MenuItem', MenuItem)
app.component('Icon', Icon)
app.component('IHeader', Header)
app.component('Card', Card)
app.component('IInput', Input)
app.component('IForm', Form)
app.component('FormItem', FormItem)
app.component('Spin', Spin)
app.component('Checkbox', Checkbox)
app.component('Affix', Affix)
app.component('Tag', Tag)
app.component('Divider', Divider)
app.component('Radio', Radio)
app.component('RadioGroup', RadioGroup)
app.component('Collapse', Collapse)
app.component('Panel', Panel)
app.component('Tooltip', Tooltip)
app.component('ISelect', Select)
app.component('IOption', Option)
app.component('Cell', Cell)
app.component('CellGroup', CellGroup)
app.component('ContentPlaceholders', ContentPlaceholders)
app.component('ContentPlaceholdersText', ContentPlaceholdersText)

app.use(router)
app.use(store)

app.use(DynamicModal)
app.use(DynamicDrawer)
app.use(DynamicPopover)

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('app')) {
    app.mount('#app')
  }
})
