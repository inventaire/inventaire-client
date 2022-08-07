import preq from '#lib/preq'

export const getListWithSelectionsById = async id => {
  return preq.get(app.API.lists.byId(id))
}

export const getListsByCreator = async userId => {
  return preq.get(app.API.lists.byCreators(userId))
}

export const createList = async list => {
  return preq.post(app.API.lists.create, list)
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

export const serializeList = list => {
  const { _id: id } = list
  return Object.assign(list, {
    pathname: `/lists/${id}`
  })
}
