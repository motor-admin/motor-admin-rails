import { i18nDict } from 'utils/scripts/configs'

function fieldRequiredMessage (field) {
  return i18nDict.field_is_required.replace('%{field}', i18nDict[field])
}

export { i18nDict, fieldRequiredMessage }
