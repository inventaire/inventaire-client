module.exports =
  UpdateModelIdRev: (model)->
    updater = (res)->
      { id, rev} = res
      model.set
        _id: id
        _rev: rev

  Rewind: (model, collection)->
    rewinder = (err)->
      collection.remove(model)
      throw err