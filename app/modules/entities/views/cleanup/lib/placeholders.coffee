{ startLoading } = require 'modules/general/plugins/behaviors'

createPlaceholders = ->
  if @_placeholderCreationOngoing then return
  @_placeholderCreationOngoing = true

  views = _.values @worksWithOrdinalRegion.currentView.children._views
  startLoading.call @, { selector: '#createPlaceholders', timeout: 300 }

  createSequentially = ->
    nextView = views.shift()
    unless nextView? then return
    nextView.create()
    .then createSequentially

  createSequentially()
  .then =>
    @_placeholderCreationOngoing = false
    @updatePlaceholderCreationButton()

removePlaceholder = (ordinalInt)->
  existingModel = @worksWithOrdinal.findWhere { ordinal: ordinalInt }
  if existingModel? and existingModel.get('isPlaceholder')
    @worksWithOrdinal.remove existingModel

removePlaceholdersAbove = (num)->
  toRemove = @worksWithOrdinal.filter (model)->
    model.get('isPlaceholder') and model.get('ordinal') > num
  @worksWithOrdinal.remove toRemove

module.exports = { createPlaceholders, removePlaceholder, removePlaceholdersAbove }
