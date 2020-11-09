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
