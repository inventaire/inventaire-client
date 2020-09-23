GeneralInfobox = require './general_infobox'
clampedExtract = require '../lib/clamped_extract'

module.exports = GeneralInfobox.extend
  template: require './templates/publisher_infobox'
  serializeData: ->
    attrs = @model.toJSON()
    clampedExtract.setAttributes attrs
    return attrs
