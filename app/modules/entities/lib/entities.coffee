module.exports =
  getReverseClaims: (property, uri, refresh, sort)->
    _.preq.get app.API.entities.reverseClaims(property, uri, refresh, sort)
    .get 'uris'
