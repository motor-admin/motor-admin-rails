import { canCanRules } from 'utils/scripts/configs'

const rulesIndex = {}

function fetchRules (action, subject) {
  const indexKey = action + subject
  const fromIndex = rulesIndex[indexKey]

  if (fromIndex) {
    return fromIndex
  } else {
    const rules = optimizeOrder(relevantRules(canCanRules, action, subject).reverse())
    rulesIndex[indexKey] = rules

    return rules
  }
}

function checkAction (abilityAction, checkedAction, isCannot) {
  return abilityAction === 'manage' || abilityAction === checkedAction || (isCannot && checkedAction === 'manage')
}

function checkSubject (abilitySubject, checkedSubject) {
  return abilitySubject === 'all' || abilitySubject === checkedSubject
}

function checkConditions (conditions, resource) {
  return Object.entries(conditions).reduce((acc, [key, value]) => {
    if (Array.isArray(value)) {
      return acc && value.some((val) => checkCondition(resource, key, val))
    } else if (value instanceof Object) {
      return acc && checkConditions(value, resource[key] || {})
    } else {
      return acc && checkCondition(resource, key, value)
    }
  }, true)
}

function checkCondition (resource, key, value) {
  return Array.isArray(resource)
    ? resource.some((item) => value?.toString().includes(item[key]?.toString()))
    : value?.toString() === resource[key]?.toString()
}

function relevantRules (rules, action, subject) {
  return rules.filter((rule) => {
    return rule.subjects.find((ruleSubject) => checkSubject(ruleSubject, subject)) &&
      rule.actions.find((ruleAction) => checkAction(ruleAction, action, !rule.base_behavior)) &&
      (rule.base_behavior || !rule.attributes.length || Object.keys(rule.conditions).length)
  })
}

function optimizeOrder (rules) {
  let firstCanInGroup = -1

  rules.forEach((rule, i) => {
    if (!rule.base_behavior) {
      firstCanInGroup = -1

      return
    }

    if (firstCanInGroup === -1) {
      firstCanInGroup = i
      return
    }

    if (rule.subjects.lenght !== 1 || rule.subjects[0] !== 'all') {
      return
    }

    rules[i] = rules[firstCanInGroup]
    rules[firstCanInGroup] = rule

    firstCanInGroup += 1
  })

  return rules
}

export default {
  $can (action, subject, resource = null) {
    const rule = fetchRules(action, subject).find((rule) => {
      return resource ? checkConditions(rule.conditions, resource) : true
    })

    if (action === 'manage' && subject === 'all') {
      return rule ? rule.base_behavior && !canCanRules.some((r) => !r.base_behavior) : false
    }

    return rule ? rule.base_behavior : false
  },
  install (app, options) {
    app.config.globalProperties.$can = (action, subject, resource = null) => this.$can(action, subject, resource)
  }
}
