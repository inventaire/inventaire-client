module.exports =
  UpdateModelIdRev: (model)->
    updater = (res)->
      # handle cases when the couch res (id, rev)
      # or the doc (_id, _rev) is returned
      { _id, _rev, id, rev } = res
      id or= _id
      rev or= _rev
      model.set
        _id: id
        _rev: rev

  Rewind: (model, collection)->
    rewinder = (err)->
      collection.remove(model)
      throw err