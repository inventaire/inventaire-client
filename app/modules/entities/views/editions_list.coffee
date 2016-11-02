module.exports = Marionette.CompositeView.extend
  template: require './templates/editions_list'
  childViewContainer: 'ul'
  childView: require './edition_li'
