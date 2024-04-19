import { uniq } from 'underscore'
import app from '#app/app'
import { langs as activeLangs } from '#app/lib/active_languages'
import availableLangList from '#app/lib/available_lang_list'

export default function (selectedLang, labels) {
  const availableLangs = Object.keys(labels)
  const highPriorityLangs = [ app.user.lang, 'en' ]
  const allLangs = uniq(availableLangs.concat(highPriorityLangs, activeLangs))
  // No distinction is made between available langs and others
  // as we can't style the <option> element anyway
  return availableLangList(allLangs, selectedLang)
}
