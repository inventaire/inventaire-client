export default function (model, value) {
  if (!_.isNonEmptyArray(value)) return
  const [ ordinal ] = Array.from(value)
  if (!_.isPositiveIntegerString(ordinal)) return

  const ordinalInt = parseInt(ordinal)
  model.set('ordinal', ordinalInt)

  this.removePlaceholder(ordinalInt)

  this.worksWithoutOrdinal.remove(model)
  this.worksWithOrdinal.add(model)

  // Re-render to update editions works pickers
  this.render()

  if (this.worksWithoutOrdinal.length !== 0) return
  if (this.showEditions || this.editionsTogglerChanged) return

  this.ui.editionsToggler.addClass('glowing')
};
