import { startLoading } from '#general/plugins/behaviors'

export const createPlaceholders = function () {
  if (this._placeholderCreationOngoing) return
  this._placeholderCreationOngoing = true

  const views = _.values(this.getRegion('worksWithOrdinalRegion').currentView.children._views)
  startLoading.call(this, { selector: '#createPlaceholders', timeout: 300 })

  const createSequentially = function () {
    const nextView = views.shift()
    if (nextView == null) return
    return nextView.create()
    .then(createSequentially)
  }

  return createSequentially()
  .then(() => {
    this._placeholderCreationOngoing = false
    return this.updatePlaceholderCreationButton()
  })
}

export const removePlaceholder = function (ordinalInt) {
  const existingModel = this.worksWithOrdinal.findWhere({ ordinal: ordinalInt })
  if ((existingModel != null) && existingModel.get('isPlaceholder')) {
    return this.worksWithOrdinal.remove(existingModel)
  }
}

export const removePlaceholdersAbove = function (num) {
  const toRemove = this.worksWithOrdinal.filter(model => model.get('isPlaceholder') && (model.get('ordinal') > num))
  return this.worksWithOrdinal.remove(toRemove)
}
