import { i18n } from 'modules/user/lib/i18n'
import Filterable from 'modules/general/models/filterable'
let unknownModel = null

export default function () {
  // Creating the model only once requested
  // as i18n can't be called straight away at initialization
  if (!unknownModel) {
    unknownModel = new Filterable({
      uri: 'unknown',
      label: i18n('unknown')
    })
  }

  unknownModel.isUnknown = true
  unknownModel.matchable = () => [ 'unknown', i18n('unknown') ]

  return unknownModel
};
