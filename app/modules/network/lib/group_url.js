import preq from 'lib/preq'
export default {
  ui: {
    groupNameField: '.groupNameField',
    groupUrlWrapper: 'p.group-url',
    groupUrl: '#groupUrl'
  },

  events: {
    'keyup .groupNameField': 'lazyUpdateUrl'
  },

  LazyUpdateUrl (view) {
    const groupId = view.model?.id
    return _.debounce(updateUrl.bind(view, groupId), 200)
  }
}

const updateUrl = function (groupId) {
  const name = this.ui.groupNameField.val()
  if (_.isNonEmptyString(name)) {
    return preq.get(app.API.groups.slug(name, groupId))
    .then(res => {
      this.ui.groupUrl.text(`${window.location.root}/groups/${res.slug}`)
      return this.ui.groupUrlWrapper.show()
    })
  } else {
    return this.ui.groupUrlWrapper.hide()
  }
}
