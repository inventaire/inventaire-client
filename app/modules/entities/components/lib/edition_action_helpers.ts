import { property, uniq } from 'underscore'
import { isNonEmptyArray } from '#lib/boolean_tests'
import { I18n } from '#user/lib/i18n'

export const getCounterText = editionItems => I18n('users_count_have_this_book', { smart_count: getOwnersCountPerEdition(editionItems) })

export const getOwnersCountPerEdition = editionItems => {
  if (isNonEmptyArray(editionItems)) {
    const notMainUserEditions = editionItems.filter(notMainUserOwner)
    const owners = notMainUserEditions.map(property('owner'))
    return uniq(owners).length
  }
}

const notMainUserOwner = doc => doc.owner !== app.user.id
