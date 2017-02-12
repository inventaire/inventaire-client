oneMinute = 60*1000

# Keep a copy of authors as a string on the item
module.exports = ->
  if @restricted then return

  # don't block snapshot data update just after creation
  wasntJustCreated = _.now() - @get('created') > oneMinute
  # prevent to re-update if the last update was not that long ago
  # so that grabEntity isn't called every time
  wasUpdatedLately = @get('updated') and _.now() - @get('updated') < 5*oneMinute
  if wasntJustCreated and wasUpdatedLately then return

  @grabEntity()
  .then =>
    updateEntityImage.call @
    updateAuthor.call @

updateEntityImage = ->
  # pass if the item already has a picture
  if @get('pictures')?[0]? then return

  @entity.getImageAsync()
  .then (image)=>
    if image?.url? then saveSnapshotData.call @, 'entity:image', image.url

updateAuthor = ->
  @entity.getAuthorsString()
  .then saveSnapshotData.bind(@, 'entity:authors')
  .catch _.Error('updateAuthor')

# Save snapshot data (i.e. data saved to the item document for convenience
# but whose master data live elsewhere)
# Those data shouldn't be set on the item model, as it would be sent
# to the server on @save, as long as all the other 'official' attributes
saveSnapshotData = (key, value)->
  snapshotKey = "snapshot.#{key}"
  currentValue = @get snapshotKey

  if not _.isNonEmptyString(value) or value is currentValue then return _.preq.resolved

  if @id is 'new'
    # the item wasn't created yet in the database
    # and updating right now would thus create a dupplicate
    # return a promise to keep the interface consistant
    return _.preq.delay(1000).then saveSnapshotData.bind(@, key, value)
  else
    return @lazySave snapshotKey, value
