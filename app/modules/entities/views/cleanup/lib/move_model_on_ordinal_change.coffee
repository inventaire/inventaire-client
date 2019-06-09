module.exports = (model, value)->
  unless _.isNonEmptyArray value then return
  [ ordinal ] = value
  unless _.isPositiveIntegerString ordinal then return

  ordinalInt = parseInt ordinal
  model.set 'ordinal', ordinalInt

  @removePlaceholder ordinalInt

  @withoutOrdinal.remove model
  @withOrdinal.add model

  # Re-render to update editions works pickers
  @render()

  if @withoutOrdinal.length isnt 0 then return
  if @showEditions or @editionsTogglerChanged then return

  @ui.editionsToggler.addClass 'glowing'
