<template>
  <v-ace-editor
    :value="modelValue"
    :placeholder="placeholder"
    :lang="language"
    class="code-editor"
    :wrap="true"
    style="height: 100%"
    theme="motor"
    @init="editorInit"
    @update:value="$emit('update:modelValue', $event)"
  />
</template>

<script>
import { VAceEditor } from 'vue3-ace-editor'
import ace from 'ace-builds'
import 'ace-builds/src-noconflict/mode-pgsql'
import 'ace-builds/src-noconflict/mode-liquid'
import 'ace-builds/src-noconflict/mode-markdown'
import 'ace-builds/src-noconflict/mode-graphqlschema'
import 'ace-builds/src-noconflict/ext-language_tools'
import { schema } from 'data_resources/scripts/schema'

ace.define('ace/theme/motor', ['require', 'exports', 'module', 'ace/lib/dom'], (require, exports, module) => {
  exports.isDark = false
  exports.cssClass = 'ace-motor'
  exports.cssText = `.ace-motor .ace_gutter {
background: #edf2f5;
color: slategray;
overflow : hidden;
}
.ace-motor .ace_print-margin {
display: none;
}
.ace-motor {
background-color: #FFFFFF;
color: #515a6e;
}
.ace-motor .ace_cursor {
color: slategray;
}
.ace-motor .ace_invisible {
color: rgb(191, 191, 191);
}
.ace-motor .ace_placeholder {
background-color: #edf2f5;
font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
letter-spacing: inherit;
line-height: inherit;
font-size: 14px;
opacity: 0.35;
margin: 0 5px;
transform: none;
}
.ace-motor .ace_constant.ace_buildin {
color: rgb(88, 72, 246);
}
.ace-motor .ace_constant.ace_language {
color: rgb(88, 92, 246);
}
.ace-motor .ace_constant.ace_library {
color: rgb(6, 150, 14);
}
.ace-motor .ace_invalid {
background-color: rgb(153, 0, 0);
color: white;
}
.ace-motor .ace_support.ace_function {
color: #DD4A68;
}
.ace-motor .ace_support.ace_constant {
color: #e90;
}
.ace-motor .ace_support.ace_type,
.ace-motor .ace_support.ace_class
.ace-motor .ace_support.ace_other {
color: rgb(109, 121, 222);
}
.ace-motor .ace_variable.ace_parameter {
font-style:italic;
color:#FD971F;
}
.ace-motor .ace_keyword.ace_operator {
color: #9a6e3a;
}
.ace-motor .ace_comment {
color: #236e24;
}
.ace-motor .ace_comment.ace_doc {
color: #236e24;
}
.ace-motor .ace_comment.ace_doc.ace_tag {
color: #236e24;
}
.ace-motor .ace_constant.ace_numeric {
color: #905;
}
.ace-motor .ace_variable {
color: rgb(49, 132, 149);
}
.ace-motor .ace_xml-pe {
color: rgb(104, 104, 91);
}
.ace-motor .ace_entity.ace_name.ace_function {
color: #e90;
}
.ace-motor .ace_heading {
color: #e90
}
.ace-motor .ace_list {
color: #515a6e;
}
.ace-motor .ace_marker-layer .ace_selection {
background: rgb(181, 213, 255);
}
.ace-motor .ace_marker-layer .ace_step {
background: rgb(252, 255, 0);
}
.ace-motor .ace_marker-layer .ace_stack {
background: rgb(164, 229, 101);
}
.ace-motor .ace_marker-layer .ace_bracket {
margin: -1px 0 0 -1px;
border: 1px solid rgb(192, 192, 192);
}
.ace-motor .ace_marker-layer .ace_active-line {
background: rgba(0, 0, 0, 0.07);
}
.ace-motor .ace_gutter-active-line {
background-color : #dcdcdc;
}
.ace-motor .ace_marker-layer .ace_selected-word {
background: rgb(250, 250, 255);
border: 1px solid rgb(200, 200, 250);
}
.ace-motor .ace_storage,
.ace-motor .ace_keyword,
.ace-motor .ace_meta.ace_tag {
color: #07a;
}
.ace-motor .ace_string.ace_regex {
color: rgb(255, 0, 0)
}
.ace-motor .ace_string.ace_emphasis {
color: #515a6e;
font-style: italic;
}
.ace-motor .ace_string.ace_strong {
color: #515a6e;
font-weight: bold;
}
.ace-motor .ace_string {
color: #690;
}
.ace-motor .ace_entity.ace_other.ace_attribute-name {
color: #994409;
}
.ace-motor .ace_indent-guide {
background: url("data:imagegpng;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAYAAACZgbYnAAAAE0lEQVQImWP4////f4bLly//BwAmVgd1/w11/gAAAABJRU5ErkJggg==") right repeat-y;
}
`

  const dom = require('../lib/dom')

  dom.importCssString(exports.cssText, exports.cssClass)
})

export default {
  name: 'CodeEditor',
  components: {
    VAceEditor
  },
  props: {
    modelValue: {
      type: String,
      required: false,
      default: ''
    },
    placeholder: {
      type: String,
      required: false,
      default: ''
    },
    language: {
      type: String,
      required: true
    },
    columns: {
      type: Array,
      required: false,
      default: () => []
    },
    autofocus: {
      type: Boolean,
      required: false,
      default: false
    },
    variables: {
      type: Array,
      required: false,
      default: () => []
    }
  },
  emits: ['update:modelValue', 'run'],
  computed: {
    completions () {
      if (['markdown', 'graphqlschema'].includes(this.language)) {
        return this.columnCompletions.concat(this.variablesCompletions)
      } else {
        return this.schemaCompletions.concat(this.variablesCompletions)
      }
    },
    columnCompletions () {
      return this.columns.map((column) => {
        return {
          name: column.name,
          value: column.name,
          meta: 'column'
        }
      })
    },
    variablesCompletions () {
      return this.variables.map((variable) => {
        return {
          name: variable.name,
          value: variable.name,
          meta: 'variable'
        }
      })
    },
    schemaCompletions () {
      return schema.reduce((acc, model) => {
        acc.push({
          name: model.table_name,
          value: model.table_name,
          meta: 'table'
        })

        model.columns.forEach((column) => {
          if (!column.virtual && column.reference?.reference_type !== 'has_one') {
            acc.push({
              name: column.name,
              value: column.name,
              meta: 'column'
            })
          }
        })

        return acc
      }, [])
    }
  },
  mounted () {
    this.$el.querySelector('textarea').addEventListener('keydown', this.onCmdEnter)
  },
  beforeUnmount () {
    this.$el.querySelector('textarea').removeEventListener('keydown', this.onCmdEnter)
  },
  methods: {
    editorInit (editor) {
      editor.renderer.setScrollMargin(8, 8, 0, 0)

      editor.setOptions({
        indentedSoftWrap: false,
        enableLiveAutocompletion: true,
        showPrintMargin: false,
        highlightActiveLine: false,
        highlightGutterLine: false
      })

      const languageTools = ace.require('ace/ext/language_tools')

      languageTools.addCompleter({
        getCompletions: async (editor, session, pos, prefix, callback) => {
          callback(null, this.completions)
        }
      })

      if (this.autofocus) {
        setTimeout(() => {
          editor.focus()
        }, 100)
      }
    },
    onCmdEnter (e) {
      if (e.keyCode === 13 && e.metaKey) {
        this.$emit('run')
      }
    }
  }
}
</script>

<style lang="scss">
.code-editor {
  background-color: #edf2f5;
  font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
  letter-spacing: inherit;
  line-height: inherit;
  font-size: 14px;
}
</style>
