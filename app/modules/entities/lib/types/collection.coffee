module.exports = ->
  _.extend @, specificMethods
  @childrenClaimProperty = 'wdt:P195'
  @subentitiesName = 'editions'
  @setClaimsBasedAttributes()
  @on 'change:claims', @onClaimsChange.bind(@)

specificMethods =
  setLabelFromTitle: ->
    # Take the label from the monolingual title property
    title = @get('claims.wdt:P1476.0')
    # inv collections will always have a title, but not the wikidata ones
    if title? then @set 'label', title

  setClaimsBasedAttributes: ->
    @setLabelFromTitle()

  onClaimsChange: (property, oldValue, newValue)->
    @setClaimsBasedAttributes()

  getChildrenCandidatesUris: ->
    publishersUris = @get 'claims.wdt:P123'
    unless publishersUris? then return Promise.resolve([])

    app.request 'get:entities:models', { uris: publishersUris }
    .then (models)->
      Promise.all _.invoke(models, 'initPublisherPublications')
      .then -> _.flatten _.pluck(models, 'isolatedEditionsUris')
