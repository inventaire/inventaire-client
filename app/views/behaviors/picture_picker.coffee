imageHandler = require 'lib/image_handler'

module.exports = class PicturePicker extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/behaviors/templates/picture_picker'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  initialize: ->
    pictures = @options.pictures
    if _.isString(pictures) then pictures = [pictures]

    @pictures = pictures.slice(0)
    _.extend @pictures, Backbone.Events

    @listenTo @pictures, 'add:pictures', @render

  serializeData: ->
      url:
        nameBase: 'url'
        field:
          type: 'url'
          placeholder: _.i18n 'Enter an image url'
        button:
          text: _.i18n 'Go get it!'
      pictures: @pictures

  onShow: ->
    app.execute 'modal:open'
    @selectFirst()

  onRender: -> @selectFirst()

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
    $('#availablePictures').find('figure').first().addClass('selected')

  selectPicture: (e)->
    $('#availablePictures').find('figure').removeClass('selected')
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

  validate: ->
    $('#availablePictures').find('.deleted').remove()
    selected = $('#availablePictures').find('figure.selected').find('img')
    imgs = $('#availablePictures').find('figure').find('img')
    pictures = []
    if imgs?.length > 0
      i = 0
      while i < imgs.length
        if imgs[i].src
          pictures.push imgs[i].src
        i += 1

      if selected?.length is 1
        s = selected[0].src
        pictures = _.without pictures, s
        pictures.unshift(s)

    _.log pictures, 'pictures'

    picturesToUpload = pictures.filter (pic)-> _.isDataUrl(pic)
    _.log picturesToUpload, 'picturesToUpload'

    if picturesToUpload?.length > 0
      app.lib.imageHandler.upload(picturesToUpload)
      .then (urls)=>
        updatedPictures = pictures.map (pic)->
          if _.isDataUrl(pic) then return urls.shift()
          else return pic

        _.log updatedPictures, 'updatedPictures'

        @close()
        @options.save(updatedPictures)
      .fail (err)-> _.log 'picturesToUpload fail'

    else
      @close()
      @options.save(pictures)

  close: -> app.execute 'modal:close'