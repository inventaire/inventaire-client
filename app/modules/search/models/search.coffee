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
    { query } = data
    data.pathname = "search?q=#{query}"
    return data

  updateTimestamp: -> @set 'timestamp', _.now()

  show: -> app.execute 'search:global', @get('query')
