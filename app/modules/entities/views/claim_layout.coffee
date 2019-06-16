wd_ = require 'lib/wikimedia/wikidata'
PaginatedEntities = require '../collections/paginated_entities'
EntitiesList = require './entities_list'
GeneralInfobox = require './general_infobox'
entities_ = require '../lib/entities'

{ entity: entityValueTemplate } = require 'lib/handlebars_helpers/claims_helpers'

module.exports = Marionette.LayoutView.extend
  id: 'claimLayout'
  template: require './templates/claim_layout'
  regions:
    infobox: '.infobox'
    list: '.list'

  initialize: ->
    { @property, @value, @refresh } = @options

    @waitForModel = app.request 'get:entity:model', @value, @refresh
      .then (model)=> @model = model

  onShow: ->
    @waitForModel
    .then @ifViewIsIntact('showInfobox')
    .catch @displayError

    entities_.getReverseClaims @property, @value, @refresh, true
    .then @ifViewIsIntact('showEntities')
    .catch @displayError

  showInfobox: ->
    @infobox.show new GeneralInfobox { @model }
    # Use the URI from the returned entity as it might have been redirected
    finalClaim = @property + '-' + @model.get('uri')
    app.navigate "entity/#{finalClaim}"

  showEntities: (uris)->
    collection = new PaginatedEntities null, { uris, defaultType: 'work' }

    # whitelisted properties labels are in i18n keys already, thus should not need
    # to be fetched like what 'entityValueTemplate' is doing for the entity value
    propertyValue = _.i18n wd_.unprefixify(@property)
    entityValue = entityValueTemplate @value

    @list.show new EntitiesList {
      title: "#{propertyValue}: #{entityValue}"
      customTitle: true
      collection: collection
      canAddOne: false
      standalone: true,
      refresh: @refresh
    }
