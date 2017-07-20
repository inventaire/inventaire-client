PositiveIntegerValueEditor = require './positive_integer_value_editor'

# This editor is useful for properties that are expected to have string values
# by Wikidata, but for which Inventaire restrict possible values to strings
# of positive integers only
# Use case: series ordinal (wdt:P1545)
module.exports = PositiveIntegerValueEditor.extend
  valueType: 'string'
