Item = require("../models/item")

module.exports = Items = Backbone.Collection.extend
  model: Item
  localStorage: new Backbone.LocalStorage('items')