export default {
  ongoing: {
    id: 'ongoing',
    viewFilter (view) { return !view.model.archived },
    icon: 'exchange',
    text: 'ongoing'
  },

  archived: {
    id: 'archived',
    viewFilter (view) { return view.model.archived },
    icon: 'archive',
    text: 'archived'
  },
}
