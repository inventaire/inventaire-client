module.exports = Marionette.CompositeView.extend
  template: require './templates/author_selector'
  childView: require './author_suggestion'
