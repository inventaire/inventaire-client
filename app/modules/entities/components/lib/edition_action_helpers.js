import { I18n } from '#user/lib/i18n'

export const getCounterText = editionItems => I18n('users have this book', { users_size: getUsersSizePerEdition(editionItems) })

const getUsersSizePerEdition = editionItems => {
  const notMainUserOwners = editionItems.filter(notMainUserOwner)
  return _.uniq(notMainUserOwners).length
}

const notMainUserOwner = doc => doc.owner !== app.user.id
