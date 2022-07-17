import preq from '#lib/preq'

export const getListWithSelectionsById = async id => {
  return preq.get(app.API.lists.byId(id))
}

export const updateList = async list => {
  return preq.put(app.API.lists.update, { ...list })
}
