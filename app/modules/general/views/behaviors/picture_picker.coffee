imageHandler = require 'lib/image_handler'
validateModule = require './lib/validate'

module.exports = Marionette.ItemView.extend
  template: require './templates/picture_picker'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  initialize: ->
    _.extend @, validateModule

    pictures = _.forceArray @options.pictures

    @pictures = pictures.clone()
    _.extend @pictures, Backbone.Events

    @listenTo @pictures, 'add:pictures', @render

  serializeData: ->
    urlInput: @urlInputData()
    pictures: @pictures

  urlInputData: ->
    nameBase: 'url'
    field:
      type: 'url'
      placeholder: _.i18n 'enter an image url'
    button:
      text: _.i18n 'go get it!'

  onShow: ->
    app.execute 'modal:open', 'large'
    @selectFirst()

  onRender: -> @selectFirst()

  ui:
    availablePictures: '#availablePictures > figure'
    availablePicturesImgs: '#availablePictures img'

  events:
    'click img': 'selectPicture'
    'change input#urlField': 'fetchUrlPicture'
    'click .selectPicture': 'selectPicture'
    'click .cancelDeletion': 'cancelDeletion'
    'click .deletePicture': 'deletePicture'
    'click #validate': 'validate'
    'click #cancel': 'close'
    'change input[type=file]': 'getFilesPictures'

  selectFirst: ->
    @ui.availablePictures.first().addClass('selected')

  selectPicture: (e)->
    @ui.availablePictures.removeClass('selected')
    $(e.target).parents('figure').first().addClass('selected')

  fetchUrlPicture: (e)->
    img = $('input#urlField').val()
    if _.isUrl img
      @pictures.unshift img
      @pictures.trigger('add:pictures')

  getFilesPictures: (e)->
    files = _.toArray e.target.files
    _.log files, 'files'
    files.forEach (file)=>
      if _.isObject file
        imageHandler.addDataUrlToArray(file, @pictures, 'add:pictures')
      else _.log file, 'couldnt getFilesPictures'

  # could be de-duplicated using toggleClass and toggle
  # but couldn't make it work
  deletePicture: (e)->
    $(e.target).parents('figure').first().addClass('deleted')
    .removeClass('selected')
    .find('figcaption.cancelDeletion').first().show()
  cancelDeletion: (e)->
    $(e.target).parents('figure').first().removeClass('deleted')
    .find('figcaption.cancelDeletion').first().hide()

  close: -> app.execute 'modal:close'


  deletePictures: (toDelete)->
    if toDelete.length > 0
      hostedPictures = toDelete.filter (pic)-> _.isHostedPicture(pic)
      if hostedPictures.length > 0
        return imageHandler.del hostedPictures
    _.log toDelete, 'pictures: no hosted picture to delete'