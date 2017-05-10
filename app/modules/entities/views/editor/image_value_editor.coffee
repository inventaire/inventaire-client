EditorCommons = require './editor_commons'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
files_ = require 'lib/files'
images_ = require 'lib/images'

urlInputSelector = '.imageUrl'
imagePreviewSelector = '.image-preview'

module.exports = EditorCommons.extend
  mainClassName: 'image-value-editor'
  template: require './templates/image_value_editor'

  behaviors:
    AlertBox: {}

  ui:
    urlInput: urlInputSelector
    uploadConfirmation: '.upload-confirmation'
    imagePreview: imagePreviewSelector

  initialize: ->
    @editMode = true
    @lazyRender = _.LazyRender @
    @focusTarget = 'urlInput'

  onRender: ->
    @focusOnRender()

  events:
    'click .edit, .displayModeData': 'showEditMode'
    'click .cancel': 'hideEditMode'
    'click .save': 'save'
    'click .delete': 'delete'
    # Not setting a particular selector so that any keyup event on taezaehe element triggers the event
    'keyup': 'onKeyup'
    'change input[type=file]': 'getImageUrl'
    'click .validate-upload': 'validateUpload'

  getImageUrl: (e)->
    files_.parseFileEventAsDataURL e
    .then _.first
    .then @showUploadConfirmation.bind(@)

  showUploadConfirmation: (dataUrl)->
    @ui.imagePreview.html "<img src=\"#{dataUrl}\">"
    @ui.uploadConfirmation.show()

  validateUpload: ->
    dataUrl = @ui.imagePreview.find('img')[0]?.src
    images_.getIpfsPathFromDataUrl dataUrl
    .then @_save.bind(@)
    .catch error_.Complete(imagePreviewSelector, false)
    .catch forms_.catchAlert.bind(null, @)

  save: ->
    url = @ui.urlInput.val()

    if url is @model.get('value') then return @hideEditMode()

    # parse URL
    unless _.isUrl url
      err = error_.new 'invalid URL', url
      err.selector = urlInputSelector
      return forms_.alert @, err

    _.preq.post app.API.images.convertUrl, { url }
    .get 'url'
    .then @_save.bind(@)
    .catch error_.Complete(urlInputSelector, false)
    .catch forms_.catchAlert.bind(null, @)
