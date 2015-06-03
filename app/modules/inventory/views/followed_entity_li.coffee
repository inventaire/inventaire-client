module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'followedEntityLi'
  template: require './templates/followed_entity_li'
  events:
    'a.unfollow': @follow
    'a.follow': @unfollow

  initialize: ->
    _.log @model.get('id'), 'id?'

  follow: -> app.execute 'entity:follow'
  unfollow: -> app.execute 'entity:unfollow'
