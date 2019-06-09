module.exports = (model, value)->
  unless _.isNonEmptyArray value then return
  [ ordinal ] = value
  unless _.isPositiveIntegerString ordinal then return

  ordinalInt = parseInt ordinal
  model.set 'ordinal', ordinalInt

  @removePlaceholder ordinalInt

  @worksWithoutOrdinal.remove model
  @worksWithOrdinal.add model

  # Re-render to update editions works pickers
  @render()

  if @worksWithoutOrdinal.length isnt 0 then return
  if @showEditions or @editionsTogglerChanged then return

  @ui.editionsToggler.addClass 'glowing'
