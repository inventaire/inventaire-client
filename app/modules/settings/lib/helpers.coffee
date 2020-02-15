error_ = require 'lib/error'

testAttribute = (attribute, value, validator_)->
  selector = "##{attribute}Field"
  if value is app.user.get attribute
    # Non-standard convention: 499 = client user error
    err = error_.new "that's already your #{attribute}", 499
    err.selector = selector
    throw err
  else
    validator_.pass value, selector
    return value

pickerData = (model, attribute)->
  nameBase: attribute
  special: true
  field:
    value: model.get attribute
  button:
    text: _.i18n "change #{attribute}"
    classes: 'light-blue-button postfix'

module.exports = { testAttribute, pickerData }
