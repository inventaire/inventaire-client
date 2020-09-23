module.exports = Backbone.Model.extend
  initialize: (data)->
    unless data.timestamp? then @updateTimestamp()

  savePictures: (pictures)->
    currentPictures = @get('pictures') or []
    # no need to save more than what we need/can display
    if currentPictures > 5 then return
    pictures = _.compact pictures
    updatedPictures = _.uniq(currentPictures.concat(pictures))[0..5]
    @set 'pictures', updatedPictures

  serializeData: ->
    data = @toJSON()
    { query, uri } = data
    data.pathname = if uri then "/entity/#{uri}" else "/search?q=#{query}"
    data.pictures = _.forceArray data.pictures
    data.label or= query
    return data

  updateTimestamp: -> @set 'timestamp', Date.now()

  show: ->
    [ uri, query ] = @gets 'uri', 'query'
    if uri? then app.execute 'show:entity', uri
    else app.execute 'search:global', query
