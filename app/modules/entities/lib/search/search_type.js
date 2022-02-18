import preq from '#lib/preq'

// This endpoint might return different results from one call to the next,
// making pagination suboptimal, thus this hack of calling more results
// instead of setting an offset
export default type => async (search, limit = 10, offset = 0) => {
  const { results } = await preq.get(app.API.search(type, search, offset + limit))
  return results
}
