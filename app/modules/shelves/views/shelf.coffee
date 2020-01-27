{ listingsData } = require 'modules/inventory/lib/item_creation'

module.exports = Marionette.LayoutView.extend
  class:'shelfLayout'
  template: require './templates/shelf'

  initialize: ->
    @lazyRender = _.LazyRender @

  events:
    'click .showShelfEdit': 'showEditor'
    'click a.cancelShelfEdition': 'hideEditor'
    'click #validateShelf': 'updateShelf'

  serializeData: ->
    attrs = @model.toJSON()
    attrs.listingData = listingsData()[@model.get('listing')]
    attrs.editable = @isEditable()
    return attrs

  regions:
    shelf: '.shelf'

  isEditable: ->
    return @model.get('owner') is app.user.id

  showEditor: (e)->
    $("#infoBox").hide()
    $(".shelfEditorWrapper").show().find('textarea').focus()
    e?.stopPropagation()

  hideEditor: (e)->
    $(".shelfEditorWrapper").hide()
    $("#infoBox").show()
    e?.stopPropagation()

  updateShelf: (e)->
    shelfId = @model.get('_id')
    @hideEditor()
    name = $("#shelfName").val()
    description = $("#shelfDesc").val()
    listing = 'private'
    _.preq.post app.API.shelves.update, { id:shelfId, name, description, listing }
    .catch _.Error('shelf update error')

