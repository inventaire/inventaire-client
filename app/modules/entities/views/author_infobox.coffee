module.exports = Marionette.ItemView.extend
  template: require './templates/author_infobox'
  modelEvents:
    # The extract might arrive later
    'change:extract': 'render'
