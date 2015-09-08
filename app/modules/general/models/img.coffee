images_ = require 'lib/images'

# named Img and not Image to avoid overwritting window.Image
module.exports = Backbone.NestedModel.extend
  initialize: ->
    { url, dataUrl } = @toJSON()

    input = url or dataUrl
    unless input? then throw new Error 'at least one input attribute is required'

    if url? then @initFromUrl url
    if dataUrl? then @initDataUrl dataUrl

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
    maxSize = 1024
    images_.resizeDataUrl dataUrl, maxSize
    .then @set.bind(@)
    .catch _.Error('resize')

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
    widthChange = @get('cropped.width') isnt @get('original.width')
    heightChange = @get('cropped.height') isnt @get('original.height')
    return _.log(widthChange or heightChange, 'image changed?')

  getFinalUrl: ->
    @setCroppedDataUrl()
    unless @imageHasChanged() then return _.preq.resolve @get('url')

    images_.upload
      blob: images_.dataUrlToBlob @get('croppedDataUrl')
      id: @cid
    .then _.property(@cid)
    .then _.Log('url?')
    .catch _.Error('getFinalUrl')
