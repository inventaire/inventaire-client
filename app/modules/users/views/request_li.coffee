module.exports = class RequestLi extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'request row'
  template: require './templates/request_li'