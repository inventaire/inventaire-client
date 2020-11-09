export default {
  ongoing: {
    id: 'ongoing',
    filter (transac, index, collection) { return !transac.archived },
    icon: 'exchange',
    text: 'ongoing'
  },

  archived: {
    id: 'archived',
    filter (transac, index, collection) { return transac.archived },
    icon: 'archive',
    text: 'archived'
  },
}
