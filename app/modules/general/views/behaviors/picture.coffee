behaviorsPlugin = require 'modules/general/plugins/behaviors'
cropper = require 'modules/general/lib/cropper'

module.exports = Marionette.ItemView.extend
  tagName: 'div'
  template: require './templates/picture'
  behaviors:
    Loading: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change:selected', @lazyRender

    cropper.get()
    .then => @model.waitForReady
    .then => @ready = true
    .then @lazyRender

    # the model depends on the view to get the croppedDataUrl
    # so it must have a reference to it
    @model.view = @

  serializeData: ->
    _.extend @model.toJSON(),
      classes: @getClasses()
      ready: @ready

  ui:
    figure: 'figure'
    img: '.original'

  getClasses: ->
    if @model.get('selected') then 'selected' else ''

  onRender: ->
    if @model.get('crop')
      if @ready and @model.get 'selected'
        @setTimeout @initCropper.bind(@), 200

  initCropper: ->
    # don't use a ui object to get the img
    # as the .selected class is added and removed
    # while the ui object is not being updated
    @ui.img.cropper
      aspectRatio: 1 / 1
      minCropBoxWidth: 300
      minCropBoxHeight: 300

  getCroppedDataUrl: (outputQuality = 1)->
    data = @ui.img.cropper 'getData'
    canvas = @ui.img.cropper 'getCroppedCanvas'
    data.dataUrl = canvas.toDataURL 'image/jpeg', outputQuality
    return data
