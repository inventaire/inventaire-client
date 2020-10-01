export default Marionette.ItemView.extend({
  className: 'result',
  tagName: 'li',
  template: require('./templates/result'),
  behaviors: {
    PreventDefault: {}
  },

  serializeData () {
    const attrs = this.model.toJSON()
    // Prefer the alias type name to show 'author' instead of 'human'
    attrs.type = attrs.typeAlias || attrs.type
    if (_.isArray(attrs.image)) { attrs.image = attrs.image[0] }
    attrs.image = urlifyImageHash(attrs.type, attrs.image)
    return attrs
  },

  events: {
    'click a': 'showResultFromEvent'
  },

  showResultFromEvent (e) { if (!_.isOpenedOutside(e)) { this.showResult() } },
  showResult () {
    const { id, uri, label, type, image } = this.model.toJSON()
    switch (type) {
    case 'users':
      app.execute('show:inventory:user', id)
      break
    case 'groups':
      app.execute('show:inventory:group:byId', { groupId: id })
      break
    case 'subjects':
      app.execute('show:claim:entities', 'wdt:P921', uri)
      break
    default:
      // Other cases are all entities
      app.execute('show:entity', uri)
    }

    if (uri != null) {
      const pictures = _.forceArray(image).map(urlifyImageHash.bind(null, type))
      app.request('search:history:add', { uri, label, type, pictures })
    }

    return app.vent.trigger('live:search:show:result')
  },

  unhighlight () { this.$el.removeClass('highlight') },
  highlight () { this.$el.addClass('highlight') }
})

const urlifyImageHash = function (type, hash) {
  const nonEntityContainer = nonEntityContainersPerType[type]
  const container = nonEntityContainer || 'entities'
  if (_.isImageHash(hash)) {
    return `/img/${container}/${hash}`
  } else { return hash }
}

const nonEntityContainersPerType = {
  users: 'users',
  groups: 'users'
}
