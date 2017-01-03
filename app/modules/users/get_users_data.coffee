module.exports = (ids, format='index', refresh)->
  ids = _.forceArray ids

  if ids.length is 0
    promise = _.preq.resolve {}
  else
    promise = getUsersByIds ids

  return promise
  .then formatData.bind(null, format)

getUsersByIds = (ids)-> _.preq.get app.API.users.data(ids)

formatData = (format, data)->
  if format is 'collection' then return _.values data
  else return data
