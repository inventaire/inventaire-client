Imgs = require 'modules/general/collections/imgs'
images_ = require 'lib/images'
files_ = require 'lib/files'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
cropper = require 'modules/general/lib/cropper'
getActionKey = require 'lib/get_action_key'

module.exports = Marionette.CompositeView.extend
  className: ->
    { limit } = @options
    "picture-picker limit-#{limit}"

  template: require './templates/picture_picker'
  childViewContainer: '#availablePictures'
  childView: require './picture'

  behaviors:
    General: {}
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}
    PreventDefault: {}

  initialize: ->
    @limit = @options.limit or 1
    pictures = _.forceArray @options.pictures
    cropper.prepare()
    collectionData = pictures.map getImgData.bind(null, @options.crop)
    @collection = new Imgs collectionData
    @listenTo @collection, 'invalid:image', @onInvalidImage.bind(@)

  serializeData: ->
    urlInput: @urlInputData()

  urlInputData: ->
    nameBase: 'url'
    field:
      type: 'url'
      placeholder: _.i18n 'enter an image url'
    button:
      text: _.i18n 'go get it!'
    allowMultiple: @limit > 1

  onShow: ->
    app.execute 'modal:open', 'large', @options.focus
    @selectFirst()
    @ui.urlInput.focus()

  ui:
    urlInput: '#urlField'

  events:
    'click #validate': 'validate'
    'click #cancel': 'close'
    'change input[type=file]': 'getFilesPictures'
    'click #urlButton': 'fetchUrlPicture'
    'keyup input[type=file]': 'preventUnwantedModalClose'

  selectFirst: ->
    @collection.models[0]?.select()

  validate: ->
    behaviorsPlugin.startLoading.call @,
      selector: '#validate'
      # The upload might take longer than the default 30 secondes,
      # so here is a very permissive 10 minutes, for the case a user
      # uploads a big picture with a slow connexion
      timeout: 600

    @getFinalUrls()
    .catch error_.Complete('.alertBox')
    .then _.Log('final urls')
    .then @_saveAndClose.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  getFinalUrls: ->
    selectedModels = @collection.models.filter isSelectedModel
    selectedModels = selectedModels.slice 0, @limit
    Promise.all _.invoke(selectedModels, 'getFinalUrl')

  _saveAndClose: (urls)->
    if urls.length > 0 then @options.save urls
    @close()

  fetchUrlPicture: (e)->
    url = @ui.urlInput.val()

    # use the full definition image:
    # - allow better resolution if the url size was small
    # - allow to host the image only once has the image hash will be the same
    url = images_.getNonResizedUrl url

    Promise.try validateUrlInput.bind(null, url)
    .then images_.getUrlDataUrl.bind(null, url)
    .then @_addToPictures.bind(@)
    .catch error_.Complete('#urlField')
    .catch forms_.catchAlert.bind(null, @)

  getFilesPictures: (e)->
    # Hide any remaing alert box
    @$el.trigger 'hideAlertBox'

    files_.parseFileEventAsDataURL e
    .then _.Log('filesDataUrl')
    .map @_addToPictures.bind(@)

  _addToPictures: (dataUrl)->
    if @limit is 1 then @_unselectAll()
    @_addDataUrlToCollection dataUrl

  _unselectAll: (dataUrl)->
    @collection.invoke 'set', 'selected', false

  _addDataUrlToCollection: (dataUrl)->
    @collection.add
      dataUrl: dataUrl
      selected: true
      crop: @options.crop

  onInvalidImage: (err)->
    err.selector = '#fileField'
    forms_.alert @, err

  close: -> app.execute 'modal:close'

  preventUnwantedModalClose: (e)->
    key = getActionKey e
    if key is 'esc'
      # prevent that closing the file picker with ESC to trigger modal:close
      _.log 'stopped ESC propagation'
      e.stopPropagation()

isSelectedModel = (model)-> model.get('selected')

validateUrlInput = (url)->
  unless _.isUrl url
    forms_.throwError 'invalid url', '#urlField', arguments

getImgData = (crop, url)-> { url, crop }
