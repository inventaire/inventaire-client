EditorCommons = require './editor_commons'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
urlInputSelector = '.imageUrl'

module.exports = EditorCommons.extend
  mainClassName: 'image-value-editor'
  template: require './templates/image_value_editor'

  behaviors:
    AlertBox: {}

  ui:
    urlInput: urlInputSelector

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

  save: ->
    url = @ui.urlInput.val()

    if url is @model.get('value') then return @hideEditMode()

    # parse URL
    unless _.isUrl url
      err = error_.new 'invalid URL', url
      err.selector = urlInputSelector
      return forms_.alert @, err


    _.preq.post app.API.images.convertUrl, { url }
    .then saveUrl.bind(@)
    .catch error_.Complete(urlInputSelector, false)
    .catch forms_.catchAlert.bind(null, @)

saveUrl = (res)->
  { url } = res
  @_save url
