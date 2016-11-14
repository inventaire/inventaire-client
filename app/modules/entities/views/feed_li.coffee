module.exports = Marionette.ItemView.extend
  template: require './templates/feed_li'
  className: 'feedLi'
  modelEvents:
    # Required for entity that deduce their label from another entity (e.g. edtions)
    'change': 'render'
