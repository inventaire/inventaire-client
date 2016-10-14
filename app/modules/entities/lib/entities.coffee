module.exports =
  getReverseClaims: (property, uri, refresh)->
    _.preq.get app.API.entities.reverseClaims(property, uri, refresh)
    .get 'uris'
