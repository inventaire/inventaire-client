module.exports =
  getReverseClaims: (property, value, refresh, sort)->
    _.preq.get app.API.entities.reverseClaims(property, value, refresh, sort)
    .get 'uris'
