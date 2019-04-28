module.exports = (type)-> (search, limit = 10, offset = 0)->
  # This endpoint might return different results from one call to the next,
  # making pagination suboptimal, thus this hack of calling more results
  # instead of setting an offset
  _.preq.get app.API.search(type, search, offset + limit)
  .get 'results'
