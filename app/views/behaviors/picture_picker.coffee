module.exports = class PicturePicker extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/behaviors/templates/picture_picker'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  initialize: ->
    @pictures = @model.get('pictures').slice(0)
    _.extend @pictures, Backbone.Events
    @listenTo @pictures, 'add:pictures', @render

  serializeData: ->
    attrs = @model.toJSON()
    _.extend attrs,
      url:
        nameBase: 'url'
        field:
          type: 'url'
          placeholder: _.i18n 'Enter an image url'
        button:
          text: _.i18n 'Go get it!'
    _.extend attrs.pictures, @pictures
    return attrs


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
      _.log imgs, 'imgs'
      _.inspect(imgs)
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
    @close()
    return app.request 'item:update',
      item: @model
      attribute: 'pictures'
      value: pictures

  close: -> app.execute 'modal:close'