export default {
  UpdateModelIdRev (model) {
    return function (res) {
    // handle cases when the couch res (id, rev)
    // or the doc (_id, _rev) is returned
      let { _id, _rev, id, rev } = res
      if (!id) { id = _id }
      if (!rev) { rev = _rev }
      return model.set({ _id: id, _rev: rev })
    }
  },

  Rewind (model, collection) {
    return function (err) {
      collection.remove(model)
      throw err
    }
  }
}
