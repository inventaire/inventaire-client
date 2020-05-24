moveToWikidata = require './lib/move_to_wikidata'
{ startLoading } = require 'modules/general/plugins/behaviors'
error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.ItemView.extend
  className: 'moveToWikidataOptions'
  template: require './templates/move_to_wikidata_options'
  onShow: -> app.execute 'modal:open', 'medium'

  serializeData: ->
    attrs = @options
    attrs.aliases = @options.aliases || {}
    return attrs

  events:
    'click #validateMoveToWikidata': 'moveToWikidata'

  moveToWikidata: (e)->
    P31Value = e.currentTarget.id
    currentP31Value = @model.get('claims')["wdt:P31"][0]
    if P31Value is currentP31Value then P31Value = null

    startLoading.call @, '#moveToWikidata'
    uri = @model.get('uri')
    moveToWikidata(uri, P31Value)
    # This should now redirect us to the new Wikidata edit page
    .then -> app.execute 'show:entity:edit', uri
    .catch error_.Complete('#moveToWikidata', false)
    .catch forms_.catchAlert.bind(null, @)
