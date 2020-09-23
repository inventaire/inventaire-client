/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Filterable from 'modules/general/models/filterable'
let unknownModel = null

export default function () {
  // Creating the model only once requested
  // as _.i18n can't be called straight away at initialization
  if (!unknownModel) {
    unknownModel = new Filterable({
      uri: 'unknown',
      label: _.i18n('unknown')
    })
  }

  unknownModel.isUnknown = true
  unknownModel.matchable = () => [ 'unknown', _.i18n('unknown') ]

  return unknownModel
};
