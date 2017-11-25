Filterable = require 'modules/general/models/filterable'
unknownModel = null

module.exports = ->
  # Creating the model only once requested
  # as _.i18n can't be called straight away at initialization
  unknownModel or= new Filterable
    uri: 'unknown'
    label: _.i18n('unknown')

  unknownModel.isUnknown = true
  unknownModel.matchable = -> [ 'unknown', _.i18n('unknown') ]

  return unknownModel
