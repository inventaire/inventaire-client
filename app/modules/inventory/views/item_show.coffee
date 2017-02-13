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
    pictureRegion: '#picture'

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'add:pictures', @lazyRender
    # use lazyRender to let the time to the item model to setUserData
    @listenTo @model, 'user:ready', @lazyRender
    @model.grabEntity()
    app.execute 'metadata:update:needed'

  onRender: ->
    @model.waitForEntity.then @showEntity.bind(@)
    @showItemData()

  onShow: ->
    # needs to be run only once
    @model.updateMetadata()
    .finally app.Execute('metadata:update:done')

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

  events:
    'click a#changePicture': 'changePicture'

  changePicture: ->
    picturePicker = new PicturePicker
      pictures: @model.get('pictures')
      # limit: 3
      limit: 1
      save: @savePicture.bind(@)
    app.layout.modal.show picturePicker

  savePicture: (value)->
    app.request 'item:update',
      item: @model
      attribute: 'pictures'
      value: value
