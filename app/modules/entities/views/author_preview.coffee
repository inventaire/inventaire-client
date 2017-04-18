module.exports = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/author_preview'
  className: 'author-preview'

  behaviors:
    PreventDefault: {}

  events:
    'click a': 'showAuthor'

  showAuthor: (e)->
    unless _.isOpenedOutside e then app.execute 'show:entity:from:model', @model
