<template>
  <div class="richtext">
    <p v-html="i18n.queries_can_contain_variable_via_syntax_html" />
    <pre v-html="selectSimpleVariableSql" />
    <p v-html="i18n.syntax_is_used_for_if_and_if_not_conditions_html" />
    <pre v-html="selectIfElseVariableSql" />
    <p v-html="i18n.current_user_variables_are_always_passed_explicitly_and_can_he_used_html" />
    <pre v-html="selectUserVariableSql" />
  </div>
</template>

<script>
export default {
  name: 'VariablesHint',
  setup () {
    const selectSimpleVariableSql = 'SELECT * FROM users WHERE role = {{role}}'
    const selectIfElseVariableSql = 'SELECT * FROM users\n{{#role}} WHERE role = {{role}} {{/role}}\n{{^role}} WHERE role = \'admin\' {{/role}}'
    const selectUserVariableSql = 'SELECT * FROM orders as od\nJOIN sales_reps as sr ON sr.id = od.rep_id\nWHERE sr.user_id = {{current_user_id}}'

    return {
      selectSimpleVariableSql,
      selectIfElseVariableSql,
      selectUserVariableSql
    }
  }
}
</script>
