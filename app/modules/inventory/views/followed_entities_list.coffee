module.exports = Marionette.CompositeView.extend
  template: require './templates/followed_entities_list'
  childView: require './followed_entity_li'
  className: 'followedEntitiesList'
  childViewContainer: '#followedEntitiesList'

  initialize: ->
    @username = app.user.get('username')

  serializeData: ->
    label: _.i18n 'researched books'

  onShow: ->
    app.request('qLabel:update')
    _.inspect(@)
    @listenTo app.vent, 'inventory:change', (username)=>
      unless username is @username
        @destroy()
