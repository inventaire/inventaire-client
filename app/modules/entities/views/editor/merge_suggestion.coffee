forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
mergeEntities = require './lib/merge_entities'

module.exports = Marionette.ItemView.extend
  template: require './templates/merge_suggestion'
  className: -> "merge-suggestion #{@cid}"
  serializeData: ->
    attrs = @model.toJSON()
    attrs.claimsPartial = claimsPartials[@model.type]
    return attrs

  events:
    'click .merge': 'merge'

  merge: ->
    { fromEntity } = @options
    fromUri = fromEntity.get 'uri'
    toUri = @model.get 'uri'

    mergeEntities fromUri, toUri
    .then app.Execute('show:entity:from:model')
    .catch error_.Complete(".#{@cid} .merge", false)
    .catch forms_.catchAlert.bind(null, @)

claimsPartials =
  author: 'entities:author_claims'
  edition: 'entities:edition_claims'
  work: 'entities:work_claims'
  serie: 'entities:work_claims'
