GeneralInfobox = require './general_infobox'
clampedExtract = require '../lib/clamped_extract'

module.exports = GeneralInfobox.extend
  template: require './templates/author_infobox'
  serializeData: ->
    attrs = @model.toJSON()
    attrs.showDeduplicateEntityButtons = app.user.isAdmin and @options.standalone
    clampedExtract.setAttributes attrs
    attrs.standalone = @options.standalone
    return attrs
