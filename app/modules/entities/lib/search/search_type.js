import preq from '#lib/preq'

export default type => async (search, limit = 10, offset = 0) => {
  return preq.get(app.API.search({
    types: type,
    search,
    limit,
    offset,
  }))
}
