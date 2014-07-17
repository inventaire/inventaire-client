module.exports = class Contacts extends Backbone.Collection
  model: require "../models/contact"
  url: 'contacts'