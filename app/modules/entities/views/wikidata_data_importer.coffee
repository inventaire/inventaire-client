wdk = require 'lib/wikidata-sdk'

module.exports = Marionette.ItemView.extend
  className: 'wikidata-data-importer'
  template: require './templates/wikidata_data_importer'
  initialize: ->
    { @labels, @claims, @wdEntity } = @options.importData

  onShow: -> app.execute 'modal:open', 'medium'

  serializeData: ->
    labels: @labels
    claims: @claims
    wdEntity: @wdEntity.toJSON()

  events:
    'click #importData': 'importSelectedData'
    'click #mergeWithoutImport': 'mergeWithoutImport'

  importSelectedData: ->
    @dataToImport = @getDataToImport()
    @importNext()

  getDataToImport: ->
    _.toArray @$el.find('input[type="checkbox"]')
    .filter isChecked
    .map formatData

  importNext: ->
    nextData = @dataToImport.pop()
    unless nextData? then return @done()

    makeImportRequest @wdEntity, nextData
    .then @importNext.bind(@)

  mergeWithoutImport: -> @done()

  done: ->
    @options.resolve()
    app.execute 'modal:close'

isChecked = (el)-> el.attributes.checked.value is 'true'

formatData = (el)->
  { attributes:attrs } = el
  type = attrs['data-type'].value

  if type is 'label'
    lang = attrs['data-lang'].value
    label = attrs['data-label'].value
    return { type, lang, label }
  else if type is 'claim'
    property = attrs['data-property'].value
    value = attrs['data-value'].value
    return { type, property, value }

makeImportRequest = (wdEntity, data)->
  { type, lang, label, property, value } = data
  if type is 'label' then wdEntity.setLabel lang, label
  else wdEntity.setPropertyValue property, null, value
