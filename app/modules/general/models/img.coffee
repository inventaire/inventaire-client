images_ = require 'lib/images'
{ maxSize } = CONFIG.images
container = 'users'

# named Img and not Image to avoid overwritting window.Image
module.exports = Backbone.NestedModel.extend
  initialize: ->
    { url, dataUrl } = @toJSON()

    input = url or dataUrl
    unless input? then throw new Error 'at least one input attribute is required'

    if url? then @initFromUrl url
    if dataUrl? then @initDataUrl dataUrl

    @crop = @get 'crop'

  initFromUrl: (url)->
    @waitForReady = @setDataUrlFromUrl url
      .then @resize.bind(@)
      .catch _.Error('initFromUrl err')

  initDataUrl: (dataUrl)->
    @set 'originalDataUrl', dataUrl
    @waitForReady = @resize()

  setDataUrlFromUrl: (url)->
    images_.getUrlDataUrl url
    .then @set.bind(@, 'originalDataUrl')

  resize: ->
    dataUrl = @get 'originalDataUrl'
    images_.resizeDataUrl dataUrl, maxSize
    .then @set.bind(@)
    .catch (err)=>
      if err.message is 'invalid image' then @collection.invalidImage @, err
      else throw err

  select: -> @set 'selected', true

  setCroppedDataUrl: ->
    if @view?
      croppedData = @view.getCroppedDataUrl()
      { dataUrl, width, height } = croppedData
      @set
        croppedDataUrl: dataUrl
        cropped:
          width: width
          height: height

  getFinalDataUrl: ->
    @get('croppedDataUrl') or @get('dataUrl')

  imageHasChanged: ->
    finalAttribute = if @crop then 'cropped' else 'resized'

    widthChange = @_areDifferent finalAttribute, 'original', 'width'
    heightChange = @_areDifferent finalAttribute, 'original', 'height'
    return _.log(widthChange or heightChange, 'image changed?')

  _areDifferent: (a, b, value)->
    @get(a)[value] isnt @get(b)[value]

  getFinalUrl: ->
    if @crop then @setCroppedDataUrl()
    # testing the original url existance as it imageHasChanged alone
    # wouldn't detect that a new image from file
    originalUrl = @get('url')
    if originalUrl? and not @imageHasChanged() then return _.preq.resolve originalUrl

    images_.upload container,
      blob: images_.dataUrlToBlob @getFinalDataUrl()
      id: @cid
    .get @cid
    .then _.Log('url?')
