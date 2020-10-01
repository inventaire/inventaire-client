export default {
  UpdateModelIdRev: model => ({ _id, _rev, id, rev }) => {
    // handle cases when the couch res (id, rev)
    // or the doc (_id, _rev) is returned
    if (!id) id = _id
    if (!rev) rev = _rev
    return model.set({ _id: id, _rev: rev })
  },

  Rewind: (model, collection) => err => {
    collection.remove(model)
    throw err
  }
}
