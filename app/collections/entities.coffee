module.exports = class Entities extends Backbone.Collection
  initialize: -> @fetch()
  model: require 'models/non_wikidata_entity'
  localStorage: new Backbone.LocalStorage 'Entities'
  byUri: (uri)-> @findWhere {uri: uri}
  hardReset: ->
    localStorage.clear()
    @_reset()

  byDomain: (domain)->
    regex = new RegExp("^#{domain}")
    @filter (entity)->
      uri = entity.get('uri')
      if regex.test(uri) then true

  wd: -> @byDomain('wd')
  isbn: -> @byDomain('isbn')