/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { langs as activeLangs } from 'lib/active_languages'
import availableLangList from 'lib/available_lang_list'

export default function (selectedLang, labels) {
  const availableLangs = Object.keys(labels)
  const highPriorityLangs = [ app.user.lang, 'en' ]
  const allLangs = _.uniq(availableLangs.concat(highPriorityLangs, activeLangs))
  // No distinction is made between available langs and others
  // as we can't style the <option> element anyway
  return availableLangList(allLangs, selectedLang)
};
