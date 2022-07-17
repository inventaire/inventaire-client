import preq from '#lib/preq'

export const getListWithSelectionsById = async id => {
  return preq.get(app.API.lists.byId(id))
  .then(res => {
    const { lists } = res
    if (lists) return lists[id]
  })
  .catch(app.Execute('show:error'))
}

export const updateList = async list => {
  return preq.put(app.API.lists.update, { ...list })
}
