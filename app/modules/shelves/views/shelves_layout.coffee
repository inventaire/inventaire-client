ShelfModel = require '../models/shelf'
ShelvesView = require './shelves_list'
error_ = require 'lib/error'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.LayoutView.extend
  id: 'shelvesLayout'
  template: require './templates/shelves_layout'
  regions:
    shelves: '.shelves'

  onShow: ->
    getByOwner()
    .then @showFromModel.bind(@)
    .catch app.Execute('show:error')

  showFromModel: (models)->
    collection = new Backbone.Collection models
    @shelves.show new ShelvesView { collection }

getByOwner = ->
  _.preq.get app.API.shelves.byOwners(app.user.id)
  .get 'shelves'
  .then (shelves)->
    shelf = Object.values(shelves).map (shelf)->
      if shelf? then new ShelfModel shelf
      else throw error_.new 'not found', 404, { id }
