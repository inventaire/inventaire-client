wd_ = require 'lib/wikimedia/wikidata'
Works = require '../collections/works'
WorksList = require './works_list'
GeneralInfobox = require './general_infobox'

{ entity:entityValueTemplate } = require 'lib/handlebars_helpers/claims_helpers'

module.exports = Marionette.LayoutView.extend
  id: 'claimLayout'
  template: require './templates/claim_layout'
  regions:
    infobox: '.infobox'
    list: '.list'

  initialize: ->
    { @property, @value } = @options

    app.request 'get:entity:model', @value
    .then (model)=>
      @model = model
      @infobox.show new GeneralInfobox { model }

    getUris @property, @value
    .then _.Log('URIS')
    .then @ifViewIsIntact('showWorks')

  serializeData: ->

  showWorks: (uris)->
    collection = new Works null, { uris, defaultType: 'work' }

    # whitelisted properties labels are in i18n keys already, thus should not need
    # to be fetched like what 'entityValueTemplate' is doing for the entity value
    propertyValue = _.i18n wd_.unprefixify(@property)
    entityValue = entityValueTemplate @value

    @list.show new WorksList {
      title: "#{propertyValue}: #{entityValue}"
      customTitle: true
      collection: collection
      canAddOne: false
      standalone: true
    }

getUris = (property, value)->
  # TODO: use a more strict request to get only entities from whitelisted types
  # (and not things like films, songs, etc)
  _.preq.get app.API.entities.reverseClaims(property, value)
  .get 'uris'

infoboxes =
  work: './works_data'
  human: './author_infobox'
  serie: './serie_infobox'
