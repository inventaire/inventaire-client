GeneralInfobox = require './general_infobox'

module.exports = GeneralInfobox.extend
  template: require './templates/author_infobox'
  serializeData: ->
    attrs = @model.toJSON()
    attrs.showDeduplicateEntityButtons = app.user.isAdmin and @options.standalone
    return attrs
