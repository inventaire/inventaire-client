ShelfModel = require '../models/shelf'

error_ = require 'lib/error'

module.exports =
  getById: (id)->
    _.preq.get app.API.shelves.byIds(id)
    .get 'shelves'
    .then (shelves)->
      shelf = Object.values(shelves)[0]
      if shelf? then new ShelfModel shelf
      else throw error_.new 'not found', 404, { id }
