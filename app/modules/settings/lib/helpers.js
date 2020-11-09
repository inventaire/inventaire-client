import { i18n } from 'modules/user/lib/i18n'
import error_ from 'lib/error'

const testAttribute = function (attribute, value, validator_) {
  const selector = `#${attribute}Field`
  if (value === app.user.get(attribute)) {
    // Non-standard convention: 499 = client user error
    const err = error_.new(`that's already your ${attribute}`, 499)
    err.selector = selector
    throw err
  } else {
    validator_.pass(value, selector)
    return value
  }
}

const pickerData = (model, attribute) => ({
  nameBase: attribute,
  special: true,

  field: {
    value: model.get(attribute)
  },

  button: {
    text: i18n(`change ${attribute}`),
    classes: 'light-blue-button postfix'
  }
})

export { testAttribute, pickerData }
