WorkData = require 'modules/entities/views/work_data'
EditionData = require 'modules/entities/views/edition_data'
PicturePicker = require 'modules/general/views/behaviors/picture_picker'
ItemShowData = require './item_show_data'

module.exports = Marionette.LayoutView.extend
  id: 'itemShowLayout'
  template: require './templates/item_show'
  regions:
    workRegion: '#work'
    editionRegion: '#edition'
    itemData: '#itemData'

  initialize: ->
    @lazyRender = _.LazyRender @
    # use lazyRender to let the time to the item model to setUserData
    @listenTo @model, 'user:ready', @lazyRender
    @model.grabEntity()

  onShow: -> app.execute 'modal:open', 'large'

  onRender: ->
    @model.waitForEntity.then @showEntity.bind(@)
    @showItemData()

  showEntity: (entity)->
    type = entity.get 'type'
    if type is 'edition'
      entity.waitForWork.then @showEntity.bind(@)
      @editionRegion.show new EditionData { model: entity }
    else
      @workRegion.show new WorkData
        model: entity
        hidePicture: true

  showItemData: -> @itemData.show new ItemShowData { @model }
