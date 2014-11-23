imageHandler = require 'lib/image_handler'

module.exports = class PicturePicker extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require './templates/picture_picker'
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
    imgs = _.toArray($('#availablePictures').find('img'))
    urls = imgs.map (img)-> img.src

    figures = _.toArray($('#availablePictures').find('figure'))
    states = figures.map (fig)-> _.toArray(fig.classList)

    if urls.length isnt states.length
      throw 'urls and associated states not matching'


    i = 0
    toDelete = []
    toKeep = []

    console.log 'states', states, 'urls', urls
    while i < urls.length
      console.log i, 'i'
      unless states[i]?
        console.error 'missing state', states[i], states, i
      else
        if _.contains states[i], 'deleted'
          toDelete.push urls[i]
        else if _.contains(states[i], 'selected') and not @selected?
          @selected = urls[i]
        else
          toKeep.push urls[i]
      i += 1

    console.log 'toDelete', toDelete, 'toKeep', toKeep

    @deletePictures(toDelete)

    toKeep.unshift(@selected)  if @selected?

    _.log toKeep, 'toKeep'

    picturesToUpload = toKeep.filter (pic)-> _.isDataUrl(pic)
    _.log picturesToUpload, 'picturesToUpload'

    if picturesToUpload?.length > 0
      @$el.trigger 'loading'
      app.lib.imageHandler.upload(picturesToUpload)
      .then (urls)=>
        updatedPictures = toKeep.map (pic)->
          if _.isDataUrl(pic) then return urls.shift()
          else return pic

        _.log updatedPictures, 'updatedPictures'

        @close()
        @options.save(updatedPictures)
      .fail (err)-> _.log 'picturesToUpload fail'

    else
      @close()
      @options.save(toKeep)

  close: -> app.execute 'modal:close'


  deletePictures: (toDelete)->
    if toDelete.length > 0
      hostedPictures = toDelete.filter (pic)-> _.isHostedPicture(pic)
      if hostedPictures.length > 0
        return app.lib.imageHandler.del hostedPictures
    _.log toDelete, 'pictures: no hosted picture to delete'