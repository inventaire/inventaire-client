import preq from '#lib/preq'

export const getListWithSelectionsById = async id => {
  return preq.get(app.API.lists.byId(id))
  .catch(app.Execute('show:error'))
}

export const updateList = async list => {
  return preq.put(app.API.lists.update, list)
}

export const addSelection = async (id, uri) => {
  return preq.post(app.API.lists.addSelections, { id, uris: [ uri ] })
}

export const removeSelection = async (id, uri) => {
  return preq.post(app.API.lists.removeSelections, { id, uris: [ uri ] })
}
