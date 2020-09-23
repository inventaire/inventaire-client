/* eslint-disable
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export const ongoing = {
  id: 'ongoing',
  filter (transac, index, collection) { return !transac.archived },
  icon: 'exchange',
  text: 'ongoing'
}

export const archived = {
  id: 'archived',
  filter (transac, index, collection) { return transac.archived },
  icon: 'archive',
  text: 'archived'
}
